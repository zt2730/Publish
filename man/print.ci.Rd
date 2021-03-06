% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/print.ci.R
\name{print.ci}
\alias{print.ci}
\title{Print confidence intervals}
\usage{
\method{print}{ci}(x, se = FALSE, print = TRUE, ...)
}
\arguments{
\item{x}{Object containing point estimates and the corresponding
confidence intervals}

\item{se}{If \code{TRUE} add the standard error.}

\item{print}{Logical: if \code{FALSE} do not actually print
confidence intervals but just return them invisibly.}

\item{...}{passed to print}

\item{digits}{Digits for round values}

\item{format}{A string which indicates the format used for confidence intervals.
The string is passed to \code{\link{formatCI}} with two arguments: the lower and the upper
limit. For example \code{'(l;u)'} yields confidence intervals with round parenthesis in which
the upper and the lower limits are separated by semicolon.}
}
\value{
A string: the formatted confidence intervals
}
\description{
Print confidence intervals
}
\details{
This format of the confidence intervals is user-manipulable.
}
\examples{
library(lava)
m <- lvm(Y~X)
m <- categorical(m,Y~X,K=4)
set.seed(4)
d <- sim(m,24)
ci.mean(Y~X,data=d)
x <- ci.mean(Y~X,data=d)
print(x,format="(l,u)")
}
\author{
Thomas A. Gerds <tag@biostat.ku.dk>
}
\seealso{
ci plot.ci formatCI
}

