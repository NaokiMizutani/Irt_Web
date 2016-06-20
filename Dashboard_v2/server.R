
library(shiny)
library(ltm)

shinyServer(function(input, output){
  
  v0 <- reactiveValues(data=NULL)
  v1 <- reactiveValues(data=NULL)
  
  output$contents <- renderTable({
    
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    v0$data <- read.csv(inFile$datapath, header=input$header, sep=input$sep, 
                        quote=input$quote)
  })
  
  selection <- c()
  
  output$selectChecks <- renderUI({
    
    if (length(selection) < 2) {
      selection <- names(v0$data)
    }
    
    checkboxGroupInput('show_vars', 'Columns in Data to Analyze:',
                       names(v0$data), selected=selection)
  })
  
  output$plot1 <- renderPlot({
    selection <- input$show_vars
    if (is.null(selection))
      selection <- names(v0$data)
    
    data <- v0$data[, selection]
    v1$data <- ltm(data~z1, IRT.param=TRUE)
    plot.ltm(v1$data, type="ICC")
  })
  
  output$summary <- renderPrint({
    summary(v1$data)
  })
  
})