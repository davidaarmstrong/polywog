\name{summary.margEff.polywog}
\alias{summary.margEff.polywog}
\title{Summarize marginal effects}
\usage{
\method{summary}{margEff.polywog}(object, probs = seq(0, 1, by = 0.25), ...)
}
\arguments{
  \item{object}{output of \code{\link{margEff.polywog}}.}

  \item{probs}{order statistics to display.}

  \item{...}{other arguments, currently ignored.}
}
\value{
Table of results.
}
\description{
Generates a table of the average marginal effects and
quartiles (or other order statistics if requested) from a
\code{"margEff.polywog"} object.
}
\author{
Brenton Kenkel and Curtis S. Signorino
}

