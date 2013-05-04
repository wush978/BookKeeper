library(shiny)

get_path <- function(name, ...) {
  root_path <- "記帳App"
  normalizePath(sprintf("%s/%s", root_path, name), ...)
}
extra_label <- c("其他", "無")

list_account <- function(id, label) {
  account <- read.csv(get_path("account.csv", mustWork=TRUE), stringsAsFactors=FALSE)
  list(
    selectInput(inputId=id, label=label, choices=c(account$Name, extra_label)),
    textInput(inputId=sprintf("%s-extra", id), label=sprintf("%s-備注", label), value="")
  )
}

shinyServer(function(input, output) {
  output[["type-selection"]] <- renderUI({
    type <- read.csv(get_path("type.csv", mustWork=TRUE), stringsAsFactors=FALSE)
    list(
      selectInput(inputId="type", label="類別", choices=c(type$Name, extra_label), multiple=FALSE),
      textInput("type-extra", label="類別-備注", value="")
    )
  })
  output[["out-account"]] <- renderUI({
    list_account("out-account", "輸出帳戶")
  })
  output[["in-account"]] <- renderUI({
    list_account("in-account", "輸入帳戶")
  })
  output[["result"]] <- renderUI({
    tableOutput("history")
  })
  output[["history"]] <- renderTable({
    query_date <- as.Date(input$date)
    if (is.na(query_date)) stop("日期格式必須為yyyy-mm-dd")
    file_name <- get_path(format(query_date, "%Y-%m.csv"), mustWork=FALSE)
    retval <- list("日期"=format(query_date), "類別"=input$type, "金額"=as.integer(input$value), "輸出帳戶"=input[["out-account"]], "輸入帳戶" = input[["in-account"]], "手續費" = input$fee, "其他備注" = input$remark)
    if (is.na(retval[["金額"]])) { # 沒有輸入，單純查詢
      if (file.exists(file_name)) {
        retval <- read.csv(file=file_name, stringsAsFactors=FALSE)
      } else {
        stop("沒有資料")
      }
      return(retval)
    } else { # 有輸入，需要加入資料庫
      retval <- data.frame(retval, check.names=FALSE, stringsAsFactors=FALSE)
      if (file.exists(file_name)) {
        retval <- rbind(retval, read.csv(file=file_name, stringsAsFactors=FALSE))
      }
      write.csv(retval, file=file_name, row.names=FALSE, fileEncoding="utf-8")
      return(retval)
    }
  })
})
