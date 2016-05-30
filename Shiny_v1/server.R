
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

    output$summary <- renderPrint({ invisible(NULL)})
    
    data <- read.csv(inFile$datapath, header=input$header, sep=input$sep,
                     quote=input$quote)
    v$data <- ltm(data~z1, IRT.param=TRUE)
    
    plot.ltm(v$data, type="ICC")
  })

})
