
library(shiny)
library(ltm)
require(rCharts)

shinyServer(function(input, output){
  
  v0 <- reactiveValues(data=NULL)
  v1 <- reactiveValues(data=NULL)
  
  selection <- c()
  
  output$contents_w1 <- renderTable({
    
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    v0$data <- read.csv(inFile$datapath, header=input$header, sep=input$sep, 
                        quote=input$quote)
    
    selection <- names(v0$data)

    v0$data
  })
  
  output$contents_w2 <- renderTable({
    v0$data
  })
  
  
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
  
  output$myChart <- renderChart2({
    selection <- input$show_vars
    if (is.null(selection))
      selection <- names(v0$data)
    
    data <- v0$data[, selection]

    v1$data <- ltm(data~z1, IRT.param=TRUE)

    result <- v1$data
    coef0 <- result$coefficient
    coef1 <- summary(result)$coefficients
    
    valsize <- length(dimnames(coef0)[[1]])
    
    print(valsize)
    
    model2pl <- function(x, a, b){
      return (1.0 / (1.0 + exp(-1.701 * a * (x - b))))
    }
    
    data <- data.frame()
    xdata <- seq(-4.0, 4.01, by=0.1)
    for (i in 1:valsize) {
      ydata_tmp <- model2pl(xdata, a=coef0[i, 2], b=coef1[i, 1])
      data_tmp <- data.frame(type=rep(dimnames(coef0)[[1]][i], length=81), x=xdata, y=ydata_tmp)
      data <- rbind(data, data_tmp)
    }
    
    p <- hPlot(y~x, group="type", data=data, type = 'line', title = 'Item Characteristic Curves')
    p$chart(zoomType = "xy")
    p$exporting(enabled = T)
    p$xAxis(title = list(text = "Ability"), min = -4.0, max = 4.0, gridLineWidth = 1)
    p$yAxis(title = list(text = "Probability"), min = 0.0, max = 1.0, gridLineWidth = 1)
    p$plotOptions(line = list(marker = list(enabled = F), enableMouseTracking = F))
    p$legend(align = 'right', verticalAlign = 'middle', layout = 'vertical')
    p$chart(width = 600, height = 400)

    return(p)
  })
  
  output$summary <- renderPrint({
    summary(v1$data)
  })
  
})