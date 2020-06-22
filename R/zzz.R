# Files and functions that should be loaded at last when calling library(ForeCA)

.onAttach <- function(libname, pkgname){
  welcome.msg <- 
    paste0("This is 'ForeCA' version ", utils::packageVersion("ForeCA"), ". ",
           'See https://github.com/gmgeorg/ForeCA for latest updates and citation("ForeCA").\n',
           "May the ForeC be with you.")
  packageStartupMessage(welcome.msg, domain = NULL, 
                        appendLF = TRUE)
}