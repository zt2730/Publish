% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/summary.univariateTable.R
\name{summary.univariateTable}
\alias{summary.univariateTable}
\title{Preparing univariate tables for publication}
\usage{
\method{summary}{univariateTable}(object, missing = c("ifany", "always",
  "never"), n = "inNames", pvalue.stars = FALSE, pvalue.digits = 4,
  showPvalues, showTotals, ...)
}
\arguments{
\item{object}{\code{univariateTable} object as obtained with
function \code{univariateTable}.}

\item{missing}{Decides if number of missing values are shown in table.
Defaults to \code{"ifany"}, and can also be set to \code{"always"} or \code{"never"}.}

\item{n}{If not missing, show the number of subjects in each
column. If equal to \code{"inNames"}, show the numbers in
parentheses in the column names.  If missing the value
\code{object$n} is used.}

\item{pvalue.stars}{If TRUE use \code{symnum} to parse p-values
otherwise use \code{format.pval}.}

\item{pvalue.digits}{Passed to \code{format.pval}.}

\item{showPvalues}{Logical. If set to \code{FALSE} the column
\code{p-values} is removed. If missing the value
\code{object$compareGroups[[1]]==TRUE} is used.}

\item{showTotals}{Logical. If set to \code{FALSE} the column
\code{Totals} is removed. If missing the value
\code{object$showTotals} is used.}

\item{...}{passed on to \code{labelUnits}. This overwrites labels
stored in \code{object$labels}}

\item{pvalue.eps}{Passed to \code{format.pval}.}
}
\value{
Summary table
}
\description{
Summary function for univariate table
}
\details{
Collects results of univariate table in a matrix.
}
\examples{
data(Diabetes)
u <- univariateTable(gender~age+location+Q(BMI)+height+weight,
                data=Diabetes)
summary(u)
summary(u,n=NULL)
summary(u,pvalue.digits=2,"age"="Age (years)","height"="Body height (cm)")
}
\author{
Thomas A. Gerds <tag@biostat.ku.dk>
}

