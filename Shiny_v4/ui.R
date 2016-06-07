library(shiny)
library(ggplot2)  # for the diamonds dataset

shinyUI(fluidPage(
  title = 'Examples of DataTables',
  sidebarLayout(
    sidebarPanel(
      conditionalPanel(
        'input.dataset === "Selected"',
        checkboxGroupInput('show_vars', 'Columns in diamonds to show:',
                           names(iris), selected = names(iris))
      )
    ),
    mainPanel(
      tabsetPanel(
        id = 'dataset',
        tabPanel('Original', DT::dataTableOutput('mytable1')),
        tabPanel('Selected', DT::dataTableOutput('mytable2'))
      )
    )
  )
))