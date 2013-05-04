source("init.R")

result_history <- function(input) {
  renderTable({
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
}
result_insert <- function(input) {
    renderTable({
    query_date <- tryCatch({
      as.Date(input$date)
    }, error = function(e) {
      NA
    })
    if (is.na(query_date)) stop("日期格式必須為yyyy-mm-dd")
    file_name <- get_path(format(query_date, "%Y-%m.csv"), mustWork=FALSE)
    retval <- list("日期"=format(query_date), "類別"=input$type, "金額"=as.integer(input$value), "輸出帳戶"=input[["out-account"]], "輸入帳戶" = input[["in-account"]], "手續費" = input$fee, "其他備注" = input$remark)
    if (is.na(retval[["金額"]])) stop("請於「金額」欄位填入整數")
    if (input$type == extra_label[1]) { # add type
      if (input[["type-extra"]] == "") stop("請於「類別-備注」欄位填寫新增的類別名稱")
      if (sum(extra_label %in% input[["type_extra"]]) > 0) stop(paste("欄位名稱不可以為「", paste(extra_label, collapse="」 或 「"), "」", sep=""))
      src <- read.csv(get_path("type.csv", mustWork=TRUE), stringsAsFactors=FALSE)
      src <- rbind(src, data.frame(Name = input[["type-extra"]]))
      write.csv(src, file=get_path("type.csv", mustWork=TRUE), row.names=FALSE)
      retval[["類別"]] <- input[["type-extra"]]
    }
    retval <- data.frame(retval, check.names=FALSE, stringsAsFactors=FALSE)
    if (file.exists(file_name)) {
      retval <- rbind(retval, read.csv(file=file_name, stringsAsFactors=FALSE))
    }
    write.csv(retval, file=file_name, row.names=FALSE, fileEncoding="utf-8")
    return(retval)
  })
}


shinyServer(function(input, output) {
  output[["type"]] <- renderUI({
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
  output[["result"]] <- function() {
    switch(
      input$mode,
      "data" = result_insert(input),
      "statistics" = result_history(input)
    )()
  }
})
