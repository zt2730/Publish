##' Tabulate the results of a regression analysis.
##'
##' The basic use of this function is to generate a near publication worthy table from a regression
##' object. As with summary(object) reference levels of factor variables are not included. Expansion
##' of the table with such values can be performed using the "fixRegressionTable" function. Forest
##' plot can be added to the output with "plotRegressionTable".
##'
##' regressionTable produces an object (list) with the parameters deriveds. The summary function creates
##' a data frame which can be used as a (near) publication ready table.
##'
##' The table shows changes in mean for linear regression,
##' odds ratios for logistic regression (family = binomial) and hazard ratios for
##' Cox regression.
##' @title Regression table
##' @param object Fitted regression model obtained with \code{lm},
##' \code{glm} or \code{coxph}.
##' @param confint.method Method to obtain confidence
##' intervals. Default is \code{'default'} which leads to Wald type
##' intervals using the model based estimate of standard error.
##' \code{'profile'} yields profile likelihood confidence intervals,
##' available from library MASS for \code{lm} and \code{glm}
##' objects. \code{'robust'} uses the sandwich form standard error to
##' construct Wald type intervals (see
##' \code{lava::estimate.default}). \code{simultaneous} calls
##' \code{multcomp::glht} to obtain simultaneous confidence intervals.
##' @param pvalue.method Method to obtain p-values. If \code{'default'} show raw p-values.
##' If \code{'robust'} use p-value corresponding to robust standard error as provided by
##' \code{lava::estimate.default}. If \code{'simultaneous'} call
##' \code{multcomp::glht} to obtain p-values.
##' @param factor.reference Style for showing results for categorical
##' variables. If \code{'extraline'} show an additional line for the
##' reference category. If \code{'inline'} display as level
##' vs. reference.
##' @param units List of units for continuous variables. See examples.
##' @param noterms Position of terms that should be ignored. E.g., for a Cox model with a cluster(id) term, there will be no hazard ratio for variable id.
##' @param ... Not yet used
##' @return List of regression blocks
##' @examples
##' # linear regression
##' data(Diabetes)
##' f1 <- glm(bp.1s~age+gender+frame+chol,data=Diabetes)
##' summary(regressionTable(f1))
##' summary(regressionTable(f1,units=list("chol"="mmol/L","age"="years")))
##' ## with interaction
##' f2 <- glm(bp.1s~age*gender+frame+chol,data=Diabetes)
##' summary(regressionTable(f2))
##' #Add reference values
##' summary(regressionTable(f2))
##' f3 <- glm(bp.1s~age+gender*frame+chol,data=Diabetes)
##' regressionTable(f3)
##'
##' # logistic regression
##' Diabetes$hyp1 <- factor(1*(Diabetes$bp.1s>140))
##' l1 <- glm(hyp1~age+gender+frame+chol,data=Diabetes,family="binomial")
##' regressionTable(l1)
##' ## with interaction
##' l2 <- glm(hyp1~age+gender+frame*chol,data=Diabetes,family="binomial")
##' regressionTable(l2)
##' l3 <- glm(hyp1~age*gender+frame*chol,data=Diabetes,family="binomial")
##' regressionTable(l3)
##'
##' # Cox regression
##' library(survival)
##' data(pbc)
##' pbc$edema <- factor(pbc$edema,levels=c("0","0.5","1"),labels=c("0","0.5","1"))
##' c1 <- coxph(Surv(time,status!=0)~log(bili)+age+protime+sex+edema,data=pbc)
##' regressionTable(c1)
##' # with interaction
##' c2 <- coxph(Surv(time,status!=0)~log(bili)+age+protime*sex+edema,data=pbc)
##' regressionTable(c2)
##' c3 <- coxph(Surv(time,status!=0)~edema*log(bili)+age+protime+sex+edema+edema:sex,data=pbc)
##' regressionTable(c3)
##'
##' @export
##' @author Thomas A. Gerds <tag@@biostat.ku.dk>
regressionTable <- function(object,
                            confint.method=c("default","profile","robust","simultaneous"),
                            pvalue.method=c("default","robust","simultaneous"),
                            factor.reference="extraline",
                            units=NULL,
                            noterms=NULL,
                            probindex=FALSE,
                            ...){
    # {{{ model type
    if (is.character(object$family)){
        logisticRegression <- (object$family=="binomial")
        poissonRegression <- (object$family=="poisson")
    } else{
        logisticRegression <- (!is.null(object$family$family) && object$family$family=="binomial")
        poissonRegression <- (!is.null(object$family$family) && object$family$family=="poisson")
    }
    coxRegression <- any(match(class(object),c("coxph","cph"),nomatch=0))
    # }}}
    # {{{ intercept

    if ("lm" %in% class(object))
        if (names(coef(object))[1]!="(Intercept)")
            stop("This function works only for models that have an Intercept.\nI.e., you should reformulate without the `~-1' term.")

    # }}}
    # {{{ parse terms
    if (is.null(object$formula)){
        if (is.null(object$terms)){
            if (class(object$call$formula)=="name"){
                stop("Cannot extract the formula from object")
            }
            else{
                formula <- object$call$formula
            }
        } else{
              formula <- formula(object$terms)
          }
    }
    else{
        formula <- object$formula
    }
    if (is.null(object$data))
        data <- eval(object$call$data)
    else
        data <- object$data
    if (is.null(units))
        units <- attr(data,"units")
    else{
        units <- c(units,attr(data,"units"))
        units <- units[unique(names(units))]
    }
    terms <- terms(formula)
    termlabels <- attr(terms,"term.labels")
    termorder <- attr(terms,"order")
    if (length(noterms)>0 & all(noterms>0)){
        termlabels <- termlabels[-noterms]
        termorder <- termorder[-noterms]
    }
    terms1 <- termlabels[termorder==1]
    # }}}
    # {{{ types of variables/terms
    coef <- coef(object)
    termnames <- names(coef)
    factorlevels <- object$xlevels
    ## for some reason logical value variables, ie with levels
    ## TRUE, FALSE do not get xlevels in the output of glm
    islogical <- grep("TRUE$",termnames,value=TRUE)
    if (length(islogical)>0){
        logicalnames <- lapply(islogical,function(l){
                                   substring(l,1,nchar(l)-4)
                               })
        names(logicalnames) <- logicalnames
        factorlevels <- c(factorlevels,
                          lapply(logicalnames,function(l){c("FALSE","TRUE")}))
    }
    factornames <- names(factorlevels)
    ## for some reason ordinal variables get strange labels
    isordered <- grep("\\.L$",termnames,value=TRUE)
    if (length(isordered)>0){
        orderednames <- unlist(strsplit(isordered,"\\.L$"))
    }else{
         orderednames <- ""
     }
    # }}}
    # {{{ interactions
    terms2 <- parseInteractionTerms(terms,factorlevels)
    vars2 <- unique(unlist(lapply(terms2,function(x)attr(x,"variables"))))
    if (length(isordered)>0 && length(terms2)>0 &&
        any(hit <- match(vars2,sapply(isordered,function(x)substr(x,0,nchar(x)-2)),nomatch=0)))
        stop(paste0("Cannot (not yet) handle interaction terms which involve ordered factors.\nOffending term(s): ",
                    sapply(isordered,function(x)substr(x,0,nchar(x)-2))[hit]))
    ## print(unlist(terms2))
    ## contrasts <- unlist(terms2)
    # }}}
    # {{{ confidence intervals
    confint.method <- match.arg(confint.method,
                                choices=c("default","profile","robust","simultaneous"),
                                several.ok=FALSE)
    if (confint.method=="robust") {
        lava.mat <- lava::estimate(object,robust=TRUE)$coefmat
    }
    ci <- switch(confint.method,
                 "default"={stats::confint.default(object)},
                 "profile"={
                     ## FIXME: what happens if profile method does not exist for this object?
                     suppressMessages(confint(object))},
                 "robust"={
                     pvalue.method <- "robust"
                     lava.mat[,c("2.5%","97.5%"),drop=FALSE]},
                 "simultaneous"={
                     pvalue.method <- "simultaneous"
                     confint(multcomp::glht(object))$confint[,c("lwr","upr"),drop=FALSE]
                 },
                 stop(paste("Sorry, don't know this confidence interval method:",confint.method)))
    # }}}
    # {{{ p-values
    pvalue.method <- match.arg(pvalue.method,
                               choices=c("default","robust","simultaneous"),
                               several.ok=FALSE)
    pval <- switch(pvalue.method,
                   "default"={sumcoef <- coef(summary(object))
                              sumcoef[,NCOL(sumcoef),drop=TRUE]},
                   ## "lrt"={
                   ## drop1(object,test="Chisq")[,"Pr(>Chi)",drop=TRUE]
                   ## },
                   "robust"={
                       lava.mat[,c("P-value"),drop=TRUE]
                   },
                   "simultaneous"={
                       summary(multcomp::glht(object))[,c("Pr(>|z|"),drop=TRUE]
                   },stop(paste("Sorry, don't know this pvalue method:",pvalue.method)))
    ## omnibus <- drop1(object,test="Chisq")[,"Pr(>Chi)",drop=TRUE]
    # }}}
    # {{{ missing values
    ## allvars <- all.vars(delete.response(terms(formula),data=data))
    allvars <- get_all_vars(delete.response(terms(formula)),data=data)
    nmiss <- lapply(allvars,function(v)sum(is.na(v)))
    ## nmiss <- lapply(allvars,function(v){sum(is.na(v))})
    ## names(nmiss) <- names(allvars)
    ## nmiss <- NULL
    # }}}
    # {{{ blocks level 1
    ## reference.value <- ifelse((logisticRegression+coxRegression==0),0,1)
    reference.value <- 0
    blocks1 <- lapply(terms1,function(vn){
                          isfactor <- match(vn,factornames,nomatch=0)
                          isordered <- match(vn,orderednames,nomatch=0)
                          ## the regexp is supposed to catch the coefficients
                          ## in which term vn is involved
                          if (isfactor){
                              if (isordered){
                                  vn.regexp <- paste("^",vn,".[LCQ]$","|","",vn,"\\^[0-9]+$",sep="")
                              }else{
                                   levs.regexp <- paste("(",paste(factorlevels[[isfactor]],collapse="|"),")",sep="")
                                   vn.regexp <- paste("^",vn,levs.regexp,"$","|","I\\(",vn,".*",levs.regexp,"|",vn,"\\)",".*",levs.regexp,sep="")
                               }
                          } else{
                                ## protect special characters
                                vn.protect <- sub("(","\\(",vn,fixed=TRUE)
                                vn.protect <- sub(")","\\)",vn.protect,fixed=TRUE)
                                vn.regexp <- paste("^",vn.protect,"$",sep="")
                            }
                          parms <- grep(vn.regexp,termnames)
                          coef.vn <- coef[parms]
                          ci.vn <- ci[parms,,drop=FALSE]
                          p.vn <- pval[parms]
                          Missing <- NULL
                          # {{{ factor variables
                          ## varname <- all.vars(formula(paste("~",vn)),data=data)
                          ## varname <- names(get_all_vars(formula(paste("~",vn)),data=data))
                          varname <- vn
                          ## found <- match(v,names(nmiss),nomatch=0)
                          nmissvar <- nmiss[[varname]]
                          if (is.null(nmissvar)) nmissvar <- 0
                          if (isfactor){
                              if (factor.reference=="inline"){
                                  Variable <- c(vn,rep("",NROW(coef.vn)-1))
                                  Units <- paste(factorlevels[[isfactor]][-1], "vs", factorlevels[[isfactor]][1])
                                  Missing <- c(nmissvar,rep("",length(coef.vn)-1))
                              } else {
                                    Variable <- c(vn,rep("",length(coef.vn)))
                                    Units <- factorlevels[[isfactor]]
                                    Missing <- c(nmissvar,rep("",length(coef.vn)))
                                    coef.vn <- c(reference.value,coef.vn)
                                    ci.vn <- rbind(c(reference.value,reference.value),ci.vn)
                                    p.vn <- c(1,p.vn)
                                }
                          } else{
                                # }}}
                                # {{{ numeric variables
                                Variable <- vn
                                if (!is.null(units[[varname]]))
                                    Units <- units[[varname]]
                                else
                                    Units <- ""
                                if (!is.null(nmiss)){
                                    Missing <- nmiss[[varname]]
                                }
                            }
                          if (is.null(Missing)) Missing <- 0
                          block <- data.frame(Variable=Variable,
                                              Units=Units,
                                              Missing=as.character(Missing),
                                              Coefficient=coef.vn,
                                              Lower=ci.vn[,1],
                                              Upper=ci.vn[,2],
                                              Pvalue=p.vn,stringsAsFactors=FALSE)
                          rownames(block) <- NULL
                          block
                      })
    # }}}
    # }}}
    # {{{ blocks level 2
    if (length(terms2)>0){
        blocks2 <- lapply(terms2,function(t2){
                              block <- data.frame(lava::estimate(object,
                                                                 f=function(p)lapply(t2,eval,envir=sys.parent(-1)),
                                                                 robust=confint.method=="robust")$coefmat)
                              colnames(block) <- c("Coefficient","StandardError","Lower","Upper","Pvalue")
                              vars <- attr(t2,"variables")
                              miss2 <- sum(is.na(get_all_vars(formula(paste("~",vars[[1]])))))+sum(is.na(get_all_vars(formula(paste("~",vars[[2]])))))
                              block <- data.frame(Variable=attr(t2,"names"),Units="",Missing=miss2,block[,-2])
                              rownames(block) <- NULL
                              block
                          })
        names(blocks2) <- names(terms2)
    }
    # }}}
    # {{{ formatting
    names(blocks1) <- terms1
    out <- blocks1
    if (length(terms2)>0) out <- c(out,blocks2)
    if (logisticRegression)
        out <- lapply(out,function(x){
                          colnames(x) <- sub("Coefficient","OddsRatio",colnames(x))
                          x$OddsRatio <- exp(x$OddsRatio)
                          x$Lower <- exp(x$Lower)
                          x$Upper <- exp(x$Upper)
                          x
                      })
    if (coxRegression | poissonRegression)
        out <- lapply(out,function(x){
                          if (probindex){
                              colnames(x) <- sub("Coefficient","ProbIndex",colnames(x))
                              x$ProbIndex <- 100/(1+exp(x$ProbIndex))
                              tmp <- 100/(1+exp(x$Upper))
                              x$Upper <- 100/(1+exp(x$Lower))
                              x$Lower <- tmp
                              rm(tmp)
                              x
                          }else{
                               colnames(x) <- sub("Coefficient","HazardRatio",colnames(x))
                               x$HazardRatio <- exp(x$HazardRatio)
                               x$Lower <- exp(x$Lower)
                               x$Upper <- exp(x$Upper)
                               x
                           }
                      })

    attr(out,"terms1") <- terms1
    attr(out,"terms2") <- terms2
    attr(out,"factornames") <- factornames
    attr(out,"orderednames") <- orderednames
    attr(out,"model") <- switch(as.character(logisticRegression+2*coxRegression+3*poissonRegression),
                                "1"="Logistic regression",
                                "2"="Cox regression",
                                "3"="Poisson regression",
                                "Linear regression")
    class(out) <- "regressionTable"
    out
    # }}}
}
