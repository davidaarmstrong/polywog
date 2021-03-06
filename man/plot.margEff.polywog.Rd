\name{plot.margEff.polywog}
\alias{plot.margEff.polywog}
\title{Plot marginal effects}
\usage{
\method{plot}{margEff.polywog}(x, ...)
}
\arguments{
  \item{x}{output of \code{\link{margEff.polywog}}.}

  \item{...}{plotting parameters to be passed to
  \code{\link{plot.density}}.}
}
\value{
Data frame containing the variables whose densities were
plotted, invisibly.
}
\description{
Generates density plots of the observationwise marginal
effects computed by \code{\link{margEff.polywog}}.
}
\author{
Brenton Kenkel and Curtis S. Signorino
}

