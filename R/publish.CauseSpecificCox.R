##' Publish cause-specific Cox models
##'
##' The cause-specific hazard ratio's are combined into one table.
##' @title Tabulizing cause-specific hazard ratio from all causes with confidence limits and Wald test p-values.
##' @param object Cause-specific hazard model obtained with
##' \code{CSC}.
##' @param cause Show a table for this cause. If omitted, list all
##' causes.
##' @param digits Number of digits for all values except p-values.
##' @param pvalue.digits Number of digits for p-values
##' @param eps Values smaller than \code{eps} are formatted as \code{<
##' eps}.
##' @param pvalue.stars If \code{TRUE}, use star-notation for
##' p-values.
##' @param ci.format Format for confidence intervals passed to
##' @param showMissing If \code{TRUE} show number of missing values
##' per variable.
##' @param reference See \code{publish.coxph}.
##' @param output.columns Pre-select columns.
##' @param print If \code{TRUE} print the table(s).
##' @param ... passed to \code{publish.coxph}
##' @return Table with cause-specific hazard ratios, confidence limits and p-values.
##' @author Thomas Alexander Gerds
##' @examples
##' library(riskRegression)
##' library(prodlim)
##' library(pec)
##' library(survival)
##' data(Melanoma)
##'  fit1 <- CSC(list(Hist(time,status)~sex,Hist(time,status)~invasion+epicel+age),
##'             data=Melanoma)
##' publish(fit1)
##' publish(fit1,eps=0.001)
##' publish(fit1,pvalue.stars=TRUE)
##' publish(fit1,ci.format="(%1.1f, %1.1f)")
##' @export
publish.CauseSpecificCox <- function(object,
                                     cause,
                                     digits=2,
                                     pvalue.digits=4,
                                     eps=.0001,
                                     pvalue.stars=FALSE,
                                     ci.format=NULL,
                                     showMissing="ifany",
                                     reference="extraline",
                                     output.columns=NULL,
                                     print=TRUE,
                                     ...){
    if (is.null(ci.format)) ci.format <- paste("[",paste("%1.",digits,"f",sep=""),";",paste("%1.",digits,"f",sep=""),"]",sep="")
    if (missing(cause)) {
        clist <- lapply(object$models,function(m){
            m$call$data <- object$call$data
            publish(m,
                    digits=digits,
                    pvalue.digits=pvalue.digits,
                    eps=eps,
                    pvalue.stars=pvalue.stars,
                    showMissing=showMissing,
                    output.columns=output.columns,
                    print=FALSE,
                    ci.format=ci.format,
                    reference=reference,...)
        })
        cause1 <- clist[[1]]
        colnames(cause1) <- paste(names(object$models)[[1]],names(cause1),sep=".")
        cause2 <- clist[[2]]
        colnames(cause2) <- paste(names(object$models)[[2]],names(cause2),sep=".")
        ## if (all(cause1$Variable==cause2$Variable)){
        ## out <- cbind(cause1,cause2[,-c(1:2)])
        ## }
        ## else{
        out <- clist
        ## }
    } else{
        m <- object$models[[cause]]
        m$call$data <- object$call$data
        out <- publish(m,
                       digits=digits,
                       pvalue.digits=pvalue.digits,
                       eps=eps,
                       pvalue.stars=pvalue.stars,
                       showMissing=showMissing,
                       output.columns=output.columns,
                       print=FALSE,
                       ci.format=ci.format,
                       reference=reference,
                       ...)
    }
    if (print==TRUE)
        print(out)
    if (pvalue.stars==TRUE)
        cat("\nSignif. codes:  0 '***'0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1\n")
    invisible(out)
}