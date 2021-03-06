% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/plot.regressionTable.R
\name{plot.regressionTable}
\alias{plot.regressionTable}
\title{Plotting regression coefficients with confidence limits}
\usage{
\method{plot}{regressionTable}(x, xlim, xlab, ...)
}
\arguments{
\item{x}{regression table obtained with regressionTable}

\item{...}{passed to plot.ci}
}
\description{
Plotting regression coefficients with confidence limits
}
\examples{
## logistic regression
data(Diabetes)
f <- glm(bp.2s~bp.1s+age+chol+gender+location,data=Diabetes)
rtf <- regressionTable(f,factor.reference = "inline")
plot(rtf,cex=2)

## Poisson regression
data(trace)
fit <- glm(dead ~ smoking+ sex+ age+Time+offset(log(ObsTime)), family = poisson,data=trace)
rtab <- regressionTable(fit,factor.reference = "inline")
plot(rtab,xlim=c(0.85,1.15),cex=1.8,xaxis.cex=1.5)

## Cox regression
library(survival)
data(pbc)
coxfit <- coxph(Surv(time,status!=0)~age+log(bili)+log(protime)+log(albumin)+edema+sex,data=pbc)
pubcox <- publish(coxfit)
plot(pubcox,cex=1.5)
}
\author{
Thomas A. Gerds <tag@biostat.ku.dk>
}
\seealso{
regressionTable
}

