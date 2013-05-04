library(shiny)
library(shinyExt)

shinyUI({
  pageWithSidebar(
    headerPanel("R 記帳本"),
    sidebarPanel(
      datePicker("date", label="日期", default=format(Sys.Date()), format="yyyy-mm-dd"),
      htmlOutput("type-selection"),
      textInput("value", label="金額", value=""),
      htmlOutput("out-account"),
      htmlOutput("in-account"),
      textInput("fee", label="手續費", value="0"),
      textInput("remark", label="其他備注", value="無"),
      submitButton(text="送出")
    ),
    mainPanel(
      htmlOutput("result")
    )
  )
})