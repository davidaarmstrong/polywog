\name{margEff.polywog}
\alias{margEff.polywog}
\title{Marginal effects for polywog models}
\usage{
\method{margEff}{polywog}(object, xvar = NULL, drop = FALSE, ...)
}
\arguments{
  \item{object}{a fitted model of class \code{"polywog"},
  typically the output of \code{\link{polywog}}.  The
  object must have a \code{model} element, meaning it was
  fit with \code{model = TRUE}.}

  \item{xvar}{a character string containing the name of a
  raw input variable (from \code{object$varNames}).
  Partial matches are allowed.}

  \item{drop}{logical: whether to convert one-column
  matrices in the output to vectors.}

  \item{...}{other arguments, currently ignored.}
}
\value{
If \code{xvar} is specified, a numeric object containing
the marginal effect of the chosen variable at each
observation in \code{object$model}.  For factor variables,
if there are more than two levels or \code{drop = FALSE},
the returned object is a matrix; otherwise it is a vector.

If \code{xvar} is \code{NULL}, a list of such results for
each raw input variable in the model is returned.

In either case, the returned object is of class
\code{"margEff.polywog"}.
}
\description{
Computes average and observationwise marginal effects from
a fitted \code{\link{polywog}} model.
}
\details{
For input variables that are binary, logical, or factors,
\code{margEff.polywog} computes a first difference with
comparison to a reference category.  All other variables
are treated as continuous: the function computes the
partial derivative of the fitted value with respect to the
selected variable.
}
\examples{
## Using occupational prestige data
data(Prestige, package = "carData")
Prestige <- transform(Prestige, income = income / 1000)

## Fit a polywog model
## (note: using low convergence threshold to shorten computation time of the
## example, *not* recommended in practice!)
set.seed(22)
fit1 <- polywog(prestige ~ education + income | type,
                data = Prestige,
                degree = 2,
                thresh = 1e-4)

## Compute marginal effects for all variables
me1 <- margEff(fit1)
summary(me1)  # type was included linearly, hence constant effects

## Plotting density of the results
plot(me1)

## Can do the same when just examining a single variable
me2 <- margEff(fit1, xvar = "income")
summary(me2)
plot(me2)
}
\author{
Brenton Kenkel and Curtis S. Signorino
}
\seealso{
To plot the density of the observationwise marginal
effects, see \code{\link{plot.margEff.polywog}}.  For a
table of average marginal effects and order statistics,
\code{\link{summary.margEff.polywog}}.

To compute fitted values, see \code{\link{predict.polywog}}
and \code{\link{predVals}}.
}

