
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(ltm)

shinyServer(function(input, output) {
  
  v <- reactiveValues(data = NULL)

  observeEvent(input$run, {
    output$summary <- renderPrint({
      summary(v$data)
    })
  })
  
  output$distPlot <- renderPlot({
    inFile <- input$file1

    if (is.null(inFile))
      return(NULL)

    data <- read.csv(inFile$datapath, header=input$header, sep=input$sep,
                     quote=input$quote)
    v$data <- ltm(data~z1, IRT.param=TRUE)
    
    plot.ltm(v$data, type="ICC")
  })

})
