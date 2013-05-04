library(shiny)
library(shinyExt)
get_path <- function(name, ...) {
  root_path <- "記帳App"
  normalizePath(sprintf("%s/%s", root_path, name), ...)
}
extra_label <- c("其他(新增)", "無")

list_account <- function(id, label) {
  account <- read.csv(get_path("account.csv", mustWork=TRUE), stringsAsFactors=FALSE)
  list(
    selectInput(inputId=id, label=label, choices=c(account$Name, extra_label)),
    textInput(inputId=sprintf("%s-extra", id), label=sprintf("%s-備注", label), value="")
  )
}
