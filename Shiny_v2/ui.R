
shinyUI(fluidPage(
  titlePanel("Uploading Files"),
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
      actionButton("run", "Show Summary"),
      tags$hr(),
      sliderInput("rval", "Red", min = 0, max = 255, value = 100),
      sliderInput("gval", "Green", min = 0, max = 255, value = 100),
      sliderInput("bval", "Blue", min = 0, max = 255, value = 100)
    ),
    mainPanel(
      plotOutput("distPlot"),
      verbatimTextOutput("summary")      
    )
  )
))
