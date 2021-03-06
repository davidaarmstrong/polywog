\name{model.frame.polywog}
\alias{model.frame.polywog}
\title{Model frame of a polywog model}
\usage{
\method{model.frame}{polywog}(formula, ...)
}
\arguments{
  \item{formula}{a fitted model of class \code{"polywog"}
  (the argument is named \code{formula} for consistency
  with the generic function \code{\link{model.frame}})}

  \item{...}{other arguments, currently ignored (but may
  later be adapted for use as in
  \code{\link{model.frame.lm}})}
}
\value{
A data frame containing the variables used to fit the
model, with additional attributes (e.g., \code{"terms"})
used to construct a model matrix.
}
\description{
Extracts the model frame from a fitted
\code{\link{polywog}} model, as
\code{\link{model.frame.lm}} does for a fitted
\code{\link{lm}} model.
}
\author{
Brenton Kenkel and Curtis S. Signorino
}
\seealso{
\code{\link{model.matrix.polywog}} for constructing the
design matrix.
}

