% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/regressionTable.R
\name{regressionTable}
\alias{regressionTable}
\title{Regression table}
\usage{
regressionTable(object, confint.method = c("default", "profile", "robust",
  "simultaneous"), pvalue.method = c("default", "robust", "simultaneous"),
  factor.reference = "extraline", units = NULL, noterms = NULL,
  probindex = FALSE, ...)
}
\arguments{
\item{object}{Fitted regression model obtained with \code{lm},
\code{glm} or \code{coxph}.}

\item{confint.method}{Method to obtain confidence
intervals. Default is \code{'default'} which leads to Wald type
intervals using the model based estimate of standard error.
\code{'profile'} yields profile likelihood confidence intervals,
available from library MASS for \code{lm} and \code{glm}
objects. \code{'robust'} uses the sandwich form standard error to
construct Wald type intervals (see
\code{lava::estimate.default}). \code{simultaneous} calls
\code{multcomp::glht} to obtain simultaneous confidence intervals.}

\item{pvalue.method}{Method to obtain p-values. If \code{'default'} show raw p-values.
If \code{'robust'} use p-value corresponding to robust standard error as provided by
\code{lava::estimate.default}. If \code{'simultaneous'} call
\code{multcomp::glht} to obtain p-values.}

\item{factor.reference}{Style for showing results for categorical
variables. If \code{'extraline'} show an additional line for the
reference category. If \code{'inline'} display as level
vs. reference.}

\item{units}{List of units for continuous variables. See examples.}

\item{noterms}{Position of terms that should be ignored. E.g., for a Cox model with a cluster(id) term, there will be no hazard ratio for variable id.}

\item{...}{Not yet used}
}
\value{
List of regression blocks
}
\description{
Tabulate the results of a regression analysis.
}
\details{
The table shows changes in mean for linear regression,
odds ratios for logistic regression (family = binomial) and hazard ratios for
Cox regression.
}
\examples{
# linear regression
data(Diabetes)
f1 <- glm(bp.1s~age+gender+frame+chol,data=Diabetes)
regressionTable(f1)
regressionTable(f1,units=list("chol"="mmol/L","age"="years"))
## with interaction
f2 <- glm(bp.1s~age*gender+frame+chol,data=Diabetes)
regressionTable(f2)
f3 <- glm(bp.1s~age+gender*frame+chol,data=Diabetes)
regressionTable(f3)

# logistic regression
Diabetes$hyp1 <- factor(1*(Diabetes$bp.1s>140))
l1 <- glm(hyp1~age+gender+frame+chol,data=Diabetes,family="binomial")
regressionTable(l1)
## with interaction
l2 <- glm(hyp1~age+gender+frame*chol,data=Diabetes,family="binomial")
regressionTable(l2)
l3 <- glm(hyp1~age*gender+frame*chol,data=Diabetes,family="binomial")
regressionTable(l3)

# Cox regression
library(survival)
data(pbc)
pbc$edema <- factor(pbc$edema,levels=c("0","0.5","1"),labels=c("0","0.5","1"))
c1 <- coxph(Surv(time,status!=0)~log(bili)+age+protime+sex+edema,data=pbc)
regressionTable(c1)
# with interaction
c2 <- coxph(Surv(time,status!=0)~log(bili)+age+protime*sex+edema,data=pbc)
regressionTable(c2)
c3 <- coxph(Surv(time,status!=0)~edema*log(bili)+age+protime+sex+edema+edema:sex,data=pbc)
regressionTable(c3)
}
\author{
Thomas A. Gerds <tag@biostat.ku.dk>
}

