
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(ltm)

shinyServer(function(input, output) {

  output$distPlot <- renderPlot({
    inFile <- input$File1
    
    if (is.null(inFile))
      return(NULL)
    
    data <- read.csv(inFile$datapath, header=input$header, sep=input$sep, 
             quote=input$quote)
    result <- ltm(data~z1, IRT.param=TRUE)

    output$summary <- renderPrint({
      summary(result)
    })
    
    plot.ltm(result, type="ICC")
  })

})
