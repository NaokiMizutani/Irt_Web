
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
    
    selection <- c()
    data <- read.csv(inFile$datapath, header=input$header, sep=input$sep,
                     quote=input$quote)
    
    output$selectChecks <- renderUI({
      if (length(selection) < 2) {
        selection <- names(data)
      }

      checkboxGroupInput('show_vars', 'Columns in Data to Analyze:',
                         names(data), selected = selection)
    })
    
    selection = input$show_vars
    
    data2 <- data[, selection]
    
    v$data <- ltm(data2~z1, IRT.param=TRUE)
    
    plot.ltm(v$data, type="ICC")
  })
  
})

