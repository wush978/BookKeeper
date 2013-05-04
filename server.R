library(shiny)

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
    value <- as.integer(input$value)
    if (is.na(value)) {
      print("history")
      return(tableOutput("history"))
    } else {
      print("insert")
      return(tableOutput("insert"))
    } 
  })
  output[["history"]] <- renderTable({
    query_date <- tryCatch({
     as.Date(input$date)
    }, error = function(e) {
      NA
    })
    if (is.na(query_date)) stop("日期格式必須為yyyy-mm-dd")
    file_name <- get_path(format(query_date, "%Y-%m.csv"), mustWork=FALSE)
    if (file.exists(file_name)) {
      retval <- read.csv(file=file_name, stringsAsFactors=FALSE)
    } else {
      stop("沒有本月資料")
    }
    return(retval)
  })
  output[["insert"]] <- renderTable({
    browser()
    query_date <- tryCatch({
      as.Date(input$date)
    }, error = function(e) {
      NA
    })
    if (is.na(query_date)) stop("日期格式必須為yyyy-mm-dd")
    file_name <- get_path(format(query_date, "%Y-%m.csv"), mustWork=FALSE)
    retval <- list("日期"=format(query_date), "類別"=input$type, "金額"=as.integer(input$value), "輸出帳戶"=input[["out-account"]], "輸入帳戶" = input[["in-account"]], "手續費" = input$fee, "其他備注" = input$remark)
    browser()
    if (input$type == extra_label[1]) { # add type
      if (input[["type-extra"]] == "") stop("請於「類別-備注」欄位填寫新增的類別名稱")
      src <- read.csv(get_path("type.csv", mustWork=TRUE), stringsAsFactors=FALSE)
      src$Name <- c(src$Name , input[["type-extra"]])
      write.csv(src, file=get_path("type.csv", mustWork=TRUE), row.names=FALSE)
    }
    retval <- data.frame(retval, check.names=FALSE, stringsAsFactors=FALSE)
    if (file.exists(file_name)) {
      retval <- rbind(retval, read.csv(file=file_name, stringsAsFactors=FALSE))
    }
    write.csv(retval, file=file_name, row.names=FALSE, fileEncoding="utf-8")
    return(retval)
  })
})
