##' Tabulate the results of a generalized linear regression analysis.
##'
##' The table shows changes in mean for linear regression and
##' odds ratios for logistic regression (family = binomial).
##' @title Tabulize regression coefficients with confidence intervals and p-values.
##' @export
##' @param object A \code{glm} object.
##' @param confint.method See \code{regressionTable}.
##' @param pvalue.method See \code{regressionTable}.
##' @param digits Rounding digits for all numbers but the p-values.
##' @param print If \code{FALSE} do not print results.
##' @param factor.reference See \code{regressionTable}.
##' @param units See \code{regressionTable}.
##' @param ... passed to \code{summary.regressionTable} and also
##' to \code{labelUnits}.
##' @param showMissing If \code{TRUE} show number of missing values in
##' table
##' @param output.columns Select which parameters of the result are
##' shown in the table. Defaults to
##' \code{c("Coefficient","CI.95","pValue","Missing")} for linear
##' regression and to \code{c("OddsRatio","CI.95","pValue","Missing")}
##' for logistic regression. Can also include \code{StandardError}.
##' @param intercept If \code{FALSE} suppress intercept
##' @param transform Transformation for regression coefficients.
##' @param profile For logistic regression only. If \code{FALSE} run
##' with Wald confidence intervals instead of waiting for profile
##' confidence intervals.
##' @param reference Style for showing results for categorical
##' variables. If \code{"extraline"} show an additional line for the
##' reference category.
##' @return Table with regression coefficients, confidence intervals and p-values.
##' @author Thomas Alexander Gerds <tag@@biostat.ku.dk>
##' @examples
##' data(Diabetes)
##' ## Linear regression
##' f = glm(bp.2s~frame+gender+age,data=Diabetes)
##' publish(f)
##' publish(f,factor.reference="inline")
##' publish(f,pvalue.stars=TRUE)
##' publish(f,ci.format="(l,u)")
##'
##' ### interaction
##' fit = glm(bp.2s~frame+gender*age,data=Diabetes)
##' summary(fit)
##' publish(fit)
##'
##' Fit = glm(bp.2s~frame*gender+age,data=Diabetes)
##' publish(Fit)
##'
##' ## Logistic regression
##' Diabetes$hyper1 <- factor(1*(Diabetes$bp.1s>140))
##' lrfit <- glm(hyper1~frame+gender+age,data=Diabetes,family=binomial)
##' publish(lrfit)
##'
##' ### interaction
##' lrfit1 <- glm(hyper1~frame+gender*age,data=Diabetes,family=binomial)
##' publish(lrfit1)
##'
##' lrfit2 <- glm(hyper1~frame*gender+age,data=Diabetes,family=binomial)
##' publish(lrfit2)
##'
##' ## Poisson regression
##' data(trace)
##' trace <- Units(trace,list("age"="years"))
##' fit <- glm(dead ~ smoking+sex+age+Time+offset(log(ObsTime)), family="poisson",data=trace)
##' rtf <- regressionTable(fit,factor.reference = "inline")
##' summary(rtf)
##' publish(fit)
##' 
##' @export
publish.glm <- function(object,
                        confint.method,
                        pvalue.method,
                        digits=c(2,4),
                        print=TRUE,
                        factor.reference="extraline",
                        units=NULL,
                        ...){
    if (missing(confint.method)) confint.method="default"
    if (missing(pvalue.method))
        pvalue.method=switch(confint.method,
            "robust"={"robust"},
            "simultaneous"={"simultaneous"},
            "default")
    rt <- regressionTable(object,
                          confint.method=confint.method,
                          pvalue.method=pvalue.method,                          
                          factor.reference=factor.reference,
                          units=units)
    srt <- summary.regressionTable(rt,
                                   digits=digits,
                                   print=FALSE,...)
    if (print==TRUE)
        publish(srt,...)
    invisible(rt)
}
##' @export
publish.lm <- publish.glm
##' @export
publish.geeglm <- publish.glm
