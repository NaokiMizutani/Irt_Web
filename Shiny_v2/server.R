
library(shiny)
library(ltm)

shinyServer(function(input, output) {
  
  v <- reactiveValues(data = NULL)
  
  observeEvent(input$run, {
    output$summary <- renderPrint({
      summary(v$data)
    })
  })

  observeEvent(input$rval, {
    if (is.null(v$data))  return()
    
    output$distPlot <- renderPlot({
      color = rgb(input$rval/255, input$gval/255, input$bval/255)
      plot.ltm(v$data, type="ICC", col=color)
    })
  })

  observeEvent(input$gval, {
    if (is.null(v$data))  return()
    
    output$distPlot <- renderPlot({
      color = rgb(input$rval/255, input$gval/255, input$bval/255)
      plot.ltm(v$data, type="ICC", col=color)
    })
  })

  observeEvent(input$bval, {
    if (is.null(v$data))  return()
    
    output$distPlot <- renderPlot({
      color = rgb(input$rval/255, input$gval/255, input$bval/255)
      plot.ltm(v$data, type="ICC", col=color)
    })
  })
  observeEvent(input$file1, {
  output$distPlot <- renderPlot({
    inFile <- input$file1
    
    if (is.null(inFile))  return(NULL)
    
    output$summary <- renderPrint({ invisible(NULL) })
    
    data <- read.csv(inFile$datapath, header=input$header, sep=input$sep,
                     quote=input$quote)

    v$data <- ltm(data~z1, IRT.param=TRUE)
    
    plot.ltm(v$data, type="ICC")
  })
  })

})
