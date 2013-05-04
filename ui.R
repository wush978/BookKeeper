source("init.R")
submit_button <- submitButton(text="送出")

shinyUI({
  pageWithSidebar(
    headerPanel("R 記帳本"),
    sidebarPanel(
      tabsetPanel(
        id = "mode",
        tabPanel(
          title="輸入資料", 
          value="data",
          datePicker("date", label="日期", default=format(Sys.Date()), format="yyyy-mm-dd"),
          {
            type <- read.csv(get_path("type.csv", mustWork=TRUE), stringsAsFactors=FALSE)
            list(
              selectInput(inputId="type", label="類別", choices=c(type$Name, extra_label), multiple=FALSE),
              textInput("type-extra", label="類別-備注", value="")
            )
          },
          textInput("value", label="金額", value=""),
          {
            list_account("out-account", "輸出帳戶")
          },
          {
            list_account("in-account", "輸入帳戶")
          },
          textInput("fee", label="手續費", value="0"),
          textInput("remark", label="其他備注", value="無"),
          submit_button
        ),
        tabPanel(
          title="統計",
          value="statistics",
          submit_button
        )
      )
    ),
    mainPanel(
      htmlOutput("result")
    )
  )
})