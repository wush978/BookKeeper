library(shiny)
library(shinyExt)
get_path <- function(name, ...) {
  root_path <- "記帳App"
  normalizePath(sprintf("%s/%s", root_path, name), ...)
}
extra_label <- c("其他(新增)", "無")

list_util <- function(src_name, id, label) {
  src <- read.csv(get_path(src_name, mustWork=TRUE), stringsAsFactors=FALSE)
  list(
    selectInput(inputId=id, label=label, choices=c(src$Name, extra_label)),
    conditionalPanel(
      sprintf("alert(JSON.stringify(input))", id, extra_label[1]),
      textInput(inputId=sprintf("%s_extra", id), label=sprintf("%s-備注", label), value="")
    )
  )
}

# list_account <- function(id, label) {
#   account <- read.csv(get_path("account.csv", mustWork=TRUE), stringsAsFactors=FALSE)
#   list(
#     selectInput(inputId=id, label=label, choices=c(account$Name, extra_label)),
#     textInput(inputId=sprintf("%s-extra", id), label=sprintf("%s-備注", label), value="")
#   )
# }
# 
# 
# type <- read.csv(get_path("type.csv", mustWork=TRUE), stringsAsFactors=FALSE)
# list(
#   selectInput(inputId="type", label="類別", choices=c(type$Name, extra_label), multiple=FALSE),
#   conditionalPanel(
#     sprintf("input.type_extra == '%s'", extra_label[1]),
#     textInput("type_extra", label="類別-備注", value="")
#   )
# )
