
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("IRT First Trial"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      fileInput('File1', 'Choose CSV File',
                accept=c('text/csv', 'text/comma-separated-values,text/plain','.csv')),
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
                   '"')
    ),
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot"),
      verbatimTextOutput("summary")
    )
  )
))
