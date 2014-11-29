\name{publish.riskRegression}
\alias{publish.riskRegression}
\title{Publishing results of riskRegression}
\usage{
\method{publish}{riskRegression}(object, digits = 2, pvalue.digits = 4,
  eps = 0.0001, pvalue.stars = FALSE, showMissing = "ifany",
  print = TRUE, ...)
}
\arguments{
  \item{object}{object of class riskRegression as obtained
  with functions ARR and LRR.}

  \item{digits}{Number of digits for regression
  coefficients}

  \item{pvalue.digits}{Number of digits for p-values}

  \item{eps}{Eps for p-values}

  \item{pvalue.stars}{If \code{TRUE} p-values are replaced
  by stars}

  \item{showMissing}{If \code{TRUE} the numbers of missing
  values are shown in a separate column}

  \item{print}{If \code{FALSE} do not print the results}

  \item{...}{passed to \code{\link{publish.matrix}}}
}
\value{
Table with regression coefficients, confidence intervals
and p-values
}
\description{
Preparing a publishable table from riskRegression results
}
\examples{
library(prodlim)
library(riskRegression)
set.seed(20)
d <- SimCompRisk(20)
f <- ARR(Hist(time,event)~X1+X2,data=d,cause=1)
publish(f)
}
\author{
Thomas A. Gerds <tag@biostat.ku.dk>
}
\seealso{
ARR LRR
}
