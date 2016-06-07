library(shiny)

shinyUI(fluidPage(
  titlePanel("IRT Third Trial"),
  sidebarLayout(
    sidebarPanel(
      fileInput('file1', 'Choose CSV File',
                accept=c('text/csv', 
                         'text/comma-separated-values,text/plain', 
                         '.csv')),
      tags$hr(),
      checkboxInput('header', 'Header', TRUE),
      radioButtons('sep', 'Separator',
                   c(Comma=',',
                     Semicolon=';',
                     Tab='\t'),
                   ','),
      radioButtons('quote', 'Quote',
                   c(None='',
                     'Double Quote'='"',
                     'Single Quote'="'"),
                   '"'),
      tags$hr(),
      uiOutput("selectChecks"),
      tags$hr(),
      actionButton("run", "Show Summary")
    ),
    mainPanel(
      plotOutput("distPlot"),
      verbatimTextOutput("summary")
    )
  )
))
