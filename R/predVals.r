## Declare 'i' as a global variable to avoid "no visible binding for global
## variable 'i'" in R CMD check when it gets to the foreach() loop in
## predVals()
if (getRversion() >= "2.15.1")
    utils::globalVariables("i")

##
## Match supplied character string to variable names in data frame, and warn
## about no match or multiple partial matches.  Used in 'predVals', not meant to
## be called directly by users.
##
## ARGUMENTS:
##   vars: character string of supplied names
##   names: character string of names in data
##
## RETURN:
##   Indices of elements in 'names' matching elements in 'vars
##
getXcols <- function(vars, names)
{
    ## Figure out the index of 'names' corresponding to each value in 'vars' (NA
    ## for no match, 0 for multiple partial matches)
    vcols <- charmatch(vars, names)
    if (any(is.na(vcols))) {
        stop("The following variable names were not found in the fitted model: ",
             paste(vars[is.na(vcols)], collapse = ", "))
    } else if (any(vcols == 0)) {
        stop("The following names partially match mutliple variables in the fitted model: ",
             paste(vars[vcols==0], collapse = ", "))
    }

    return(vcols)
}

##
## Create the varying part of a fitted value profile.  Used in 'predVals', not
## meant to be called directly by users.
##
## ARGUMENTS:
##   data: data frame containing raw data
##   cols: columns of varying variables
##   xlims: named list specifying limits to use for continuous variables
##     (default is to use observed range)
##   n: number of grid points for continuous variables
##
## RETURN:
##   Data frame containing grid values for specified variables
##
getXvals <- function(data, cols, xlims, n)
{
    ans <- list()
    for (i in seq_along(cols)) {
        xcol <- cols[i]
        xname <- names(data)[xcol]
        x <- data[, xcol]

        ## Construct the sequence of values of the variable to evaluate at
        if (all(unique(x) %in% c(0, 1))) {
            ## Binary variable: use 0 and 1
            xs <- c(0, 1)
        } else if (is.numeric(x)) {
            ## Continuous variable: make a grid of size 'n' within the specified
            ## limits (or observed range if none specified)
            xlim <- xlims[[xname]]
            if (is.null(xlim))
                xlim <- range(x)
            xs <- seq(xlim[1], xlim[2], length.out = n)
        } else if (is.factor(x)) {
            ## Factor variable: use all levels
            xs <- factor(levels(x), levels = levels(x))
        } else if (is.logical(x)) {
            ## Logical variable: use TRUE and FALSE
            xs <- c(FALSE, TRUE)
        }

        ans[[i]] <- xs
        names(ans)[i] <- xname
    }

    ## Create all possible combinations of the specified variables
    ans <- expand.grid(ans)
    return(ans)
}

##' Easy computation of fitted values
##'
##' User-friendly generation of fitted values and their confidence intervals
##' from models of class \code{"polywog"}, using the "observed-value approach"
##' advocated by Hanmer and Kalkan (2013).
##'
##' \code{predVals} allows users to examine the estimated effects of input
##' variables on the expected outcome using the coefficients returned by
##' \code{\link{polywog}}.  The procedure is designed so that, for a preliminary
##' analysis, the user can simply specify the fitted model and the independent
##' variable of interest, and quickly obtain predicted values.
##'
##' The predicted values are generated according to Hanmer and Kalkan's (2013)
##' observed-value approach, which takes the form of a nested loop.  When
##' \code{xvars} contains a single variable \eqn{X_m}, the procedure is as
##' follows:
##' \enumerate{
##' \item For each level \eqn{x} of \eqn{X_m} in \code{data} (if \eqn{X_m}
##' is discrete) or each element \eqn{x} of a grid over the range of \eqn{X_m}
##' in \code{data} (if \eqn{X_m} is continuous):
##'
##' \enumerate{
##' \item For each observation \eqn{i} of \code{data}:
##'
##' \enumerate{
##' \item Set \eqn{X_{mi} = x}, while holding all other variables
##' \eqn{X_{-mi}} at their observed levels
##'
##' \item Compute the predicted value of \eqn{Y_i} for the modified
##' observation \eqn{i}, using the estimated model coefficients (as in
##' \code{\link{predict.polywog}})
##' }
##'
##' \item The predicted value of \eqn{Y} given \eqn{X_m = x} is the average of
##' the predictions computed in the previous step
##' }
##' }
##' 
##' This observed-value approach provides a better estimate of population
##' average effects for nonlinear models than does the traditional approach,
##' which is to vary \eqn{X_m} across its levels/range while holding each
##' other covariate to its mean or median in \code{data} (Hanmer and Kalkan
##' 2013).
##'
##' When \code{xvars} consists of multiple variables \eqn{X_1, \ldots,
##' X_M}{X_1, ..., X_M}, the \code{predVals} procedure is the same, except the
##' outer loop is over every \emph{combination} of their levels in
##' \code{data}.
##'
##' All confidence intervals are generated via the bootstrap.  Specifically,
##' \code{predVals} repeats the above procedure for each set of bootstrap
##' coefficients and computes order statistics of the resulting set of
##' averages (for each combination of levels of \code{xvars}).  If
##' \code{model} does not have a \code{boot.matrix} element (see
##' \code{\link{bootPolywog}}), confidence intervals will not be computed.
##' @param model a fitted model of class \code{"polywog"}, typically the output
##' of \code{\link{polywog}}.
##' @param xvars a character vector containing names of raw input variables
##' (from \code{model$varNames}).  Partial matches are allowed.
##' @param data data frame to treat as the observed sample (defaults to the
##' data used to fit the supplied model)
##' @param xlims named list of limits for the evaluation grid for each
##' continuous variable in \code{xvars}.  If not given, the variable's observed
##' range is used.
##' @param n number of grid points at which to evaluate each continuous variable
##' in \code{xvars}.
##' @param interval logical: whether to compute bootstrap confidence intervals
##' for each fitted value.
##' @param level confidence level for the intervals.
##' @param maxrows maximum number of rows of output.  Used to prevent accidental
##' memory overruns when \code{xvars} contains more than two continuous
##' variables.
##' @param report logical: whether to print a status bar.  Not available if
##' \code{.parallel = TRUE}.
##' @param .parallel logical: whether to perform bootstrap iterations in
##' parallel using \code{\link[foreach]{foreach}}.  See the "Details" section of
##' the \code{\link{bootPolywog}} documentation page for more on parallel
##' computation.
##' @param ... other arguments, currently ignored
##' @return A data frame containing the fitted values and confidence intervals
##' (if requested) for each combination of covariate values.
##'
##' The returned data frame also inherits from class \code{"preplot.polywog"}.
##' This is used by \code{\link{plot.polywog}}, which calls \code{predVals} to
##' compute the values to plot.
##' @seealso \code{\link{predict.polywog}} for more flexible (but less
##' user-friendly) computation of fitted values.  \code{\link{plot.polywog}} for
##' plotting fitted values and their confidence intervals.
##' @references
##' Michael J. Hanmer and Kerem Ozan Kalkan.  2013.  "Behind the Curve:
##' Clarifying the Best Approach to Calculating Predicted Probabilities and
##' Marginal Effects from Limited Dependent Variable Models."  \emph{American
##' Journal of Political Science} 57(1):263--277.
##' @author Brenton Kenkel and Curtis S. Signorino
##' @export
##' @examples
##' ## Using occupational prestige data
##' data(Prestige, package = "car")
##' Prestige <- transform(Prestige, income = income / 1000)
##'
##' ## Fit a polywog model with bootstrap iterations
##' set.seed(22)
##' fit1 <- polywog(prestige ~ education + income + type, data = Prestige,
##'                 boot = 10)
##'
##' ## Predicted prestige across occupational categories
##' predVals(fit1, "type")
##'
##' ## Predicted prestige by education
##' predVals(fit1, "education", n = 10)
##' @import foreach
##' @importMethodsFrom Matrix t
predVals <- function(model, xvars,
                     data = model$model,
                     xlims = list(), n = 100,
                     interval = TRUE, level = .95, maxrows = 10000,
                     report = FALSE, .parallel = FALSE, ...)
{
    ## Can't form a confidence interval if no bootstrap results
    if (is.null(model$boot.matrix) && interval) {
        interval <- FALSE
        warning("Option 'interval' not available for models without a 'boot.matrix' element")
    }

    ## Can't print a status bar in parallel
    if (.parallel)
        report <- FALSE

    ## Calculate grid of covariate values to examine
    xc <- getXcols(xvars, names(data))
    xv <- getXvals(data, xc, xlims, n)
    if (nrow(xv) > maxrows) {
        stop("Too many combinations of 'xvars' generated; re-run with lower n or maxrows >= ",
             nrow(xv), " to continue")
    }

    ## Loop through the grid of covariate values
    `%dofn%` <- if (.parallel) `%dopar%` else `%do%`
    if (report)
        pb <- txtProgressBar(min = 0, max = nrow(xv))
    ans <- foreach (i = seq_len(nrow(xv)), .combine = rbind) %dofn% {
        ## Replace the actual values of the selected covariates in the data
        ## with the i'th row of the grid, while keeping everything else at its
        ## true values
        data[, names(xv)] <- xv[i, ]

        ## Create the model matrix
        X <- makePlainX(model$formula, data)

        pred <- computePredict(X = X,
                               poly_terms = model$polyTerms,
                               coef = list(main = coef(model),
                               boot = if (interval) t(model$boot.matrix)),
                               forPredVals = TRUE,
                               interval = interval,
                               bag = FALSE,
                               level = level)

        if (report)
            setTxtProgressBar(pb, i)

        unlist(pred)
    }
    ans <- data.frame(cbind(xv, ans))
    rownames(ans) <- seq_len(nrow(ans))

    if (!interval)
        ans$lwr <- ans$upr <- NULL

    ans <- structure(ans,
                     interval = interval,
                     xvars = xvars,
                     xcol = seq_len(ncol(xv)),
                     class = c("preplot.polywog", "data.frame"))
    return(ans)
}
