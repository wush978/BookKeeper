library(shiny)
library(shinyExt)

shinyUI({
  pageWithSidebar(
    headerPanel("R 記帳本"),
    sidebarPanel(
      tabsetPanel(
        id = "input-type",
        tabPanel(
          title="輸入資料", 
          value="input-data",
          datePicker("date", label="日期", default=format(Sys.Date()), format="yyyy-mm-dd"),
          htmlOutput("type-selection"),
          textInput("value", label="金額", value=""),
          htmlOutput("out-account"),
          htmlOutput("in-account"),
          textInput("fee", label="手續費", value="0"),
          textInput("remark", label="其他備注", value="無"),
          submitButton(text="送出")
        ),
        tabPanel(
          title="統計",
          value="input-statistics",
          h5("developing")
        )
      )
    ),
    mainPanel(
      htmlOutput("result")
    )
  )
})