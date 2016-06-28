
library(shiny)
library(ltm)
require(rCharts)
require(data.table)
require(DT)
require(lucid)

### Common Function (IRT 2PL model)

model2pl <- function(x, a, b) {
  return (1.0 / (1.0 + exp(-1.701 * a * (x - b))))
}

### Shiny Server Main Function ###

shinyServer(function(input, output){
  
  v0 <- reactiveValues(data=NULL)
  v1 <- reactiveValues(data=NULL)
  v2 <- reactiveValues(data=NULL)
  
  selection <- c()
  
### for widget(1) 'Data Selection'

  output$contents_w1 <- renderTable({
    
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    v0$data <- read.csv(inFile$datapath, header=input$header, sep=input$sep, 
                        quote=input$quote)
    
    selection <- names(v0$data)
    v2$data <- ltm(v0$data~z1, IRT.param=TRUE)
    
    v1$data <- v0$data
  })

### for widget(2) 'Item Selection'

  output$selectChecks <- renderUI({
    
    if (length(selection) < 2) {
      selection <- names(v0$data)
    }
    
    checkboxGroupInput('show_vars', 'Items to Analyze:',
                       names(v0$data), selected=selection)
  })
  
  output$contents_w2 <- renderTable({
    v0$data
  })
  
  observeEvent(input$do,{
    selection <- input$show_vars
    if (length(selection) < 2)
      selection <- names(v0$data)
    
    v1$data <- v0$data[, selection]
    
    v2$data <- ltm(v1$data~z1, IRT.param=TRUE)
    
    output$contents_w2 <- renderTable({
      v1$data
    })
  })
  
### for widget(3) 'ICC chart / plot.ltm() function'
  
  output$plot1 <- renderPlot({
    plot.ltm(v2$data, type="ICC")
  })
  
  output$summary <- renderPrint({
    summary(v2$data)
  })

### for widget(4) 'ICC chart / HighChart javascript library'

  output$myChart <- renderChart2({

    result <- v2$data
    coef0 <- result$coefficient
    coef1 <- summary(result)$coefficients
    
    valsize <- length(dimnames(coef0)[[1]])

    data <- data.frame()
    xdata <- seq(-5.0, 5.01, by=0.1)
    for (i in 1:valsize) {
      ydata_tmp <- model2pl(xdata, a=coef0[i, 2], b=coef1[i, 1])
      data_tmp <- data.frame(type=rep(dimnames(coef0)[[1]][i], length=length(xdata)), x=xdata, y=ydata_tmp)
      data <- rbind(data, data_tmp)
    }
    
    p <- hPlot(y~x, group="type", data=data, type = 'line', title = 'Item Characteristic Curves')
    p$exporting(enabled = T)
    p$xAxis(title = list(text = "Ability"), min = -5.0, max = 5.0, gridLineWidth = 1)
    p$yAxis(title = list(text = "Probability"), min = 0.0, max = 1.0, gridLineWidth = 1)
    p$plotOptions(line = list(marker = list(enabled = F), enableMouseTracking = F))
    #    p$plotOptions(line = list(marker = list(enabled = F), enableMouseTracking = T))
    p$legend(align = 'right', verticalAlign = 'middle', layout = 'vertical')
    p$chart(zoomType = "x", width = 600, height = 400)
    
    return(p)
  })

### for widget(5) 'Table view with DataTables library'
  
  output$mytable1 <- DT::renderDataTable({

    data <- v1$data    
    result <- v2$data
    
    nitem <- dim(data)[2]
    nsample <- dim(data)[1]
    itemname <- dimnames(result$coefficient)[1]
    param_a <- result$coefficient[, 2]
    param_b <- summary(result)$coefficients[, 1]
   
    scores <- factor.scores(result, resp.pattern=data)
    
    theta <- scores$score.dat[,nitem+3]
    
    mat <- matrix(nrow=nsample, ncol=nitem)
    for (i in 1:nsample) {
      z1 <- theta[i]
      for (j in 1:nitem) {
        a <- param_a[j]
        b <- param_b[j]
        mat[i, j] <- model2pl(z1, a, b)
      }
    }
    
    probans1 <- data.frame(mat)
    names(probans1) <- paste(itemname[[1]], rep(".exp", nitem))
    
    diffans <- data - probans1
    names(diffans) <- paste(itemname[[1]], rep(".diff", nitem))
    
    result2 <- cbind(data, probans1, diffans, scores$score.dat[nitem+3])
    mydatatable <- data.table(result2)
    #    mydatatable <- data.table(v0$data)
    
    color_from_middle <- function (data, color1,color2) 
    {
      max_val=max(abs(data))
      JS(sprintf("isNaN(parseFloat(value)) || value < 0 ? 'linear-gradient(90deg, transparent, transparent ' + (50 + value/%s * 50) + '%%, %s ' + (50 + value/%s * 50) + '%%,%s  50%%,transparent 50%%)': 'linear-gradient(90deg, transparent, transparent 50%%, %s 50%%, %s ' + (50 + value/%s * 50) + '%%, transparent ' + (50 + value/%s * 50) + '%%)'",
                 max_val,color1,max_val,color1,color2,color2,max_val,max_val))
    } 
    
    color_from_left <- function (data, color) 
    {
      max_val=max(abs(data))
      JS(sprintf("isNaN(parseFloat(value)) || 'linear-gradient(90deg, transparent, transparent 0%%, %s 0%%, %s ' + (value/%s * 100) + '%%, transparent ' + (value/%s * 100) + '%%)'",
                 color,color,max_val,max_val))
    } 
    
    DT::datatable(lucid(mydatatable, dig = 6),
                  class = 'cell-border stripe',
                  extensions = c('ColReorder', 'Buttons', 'FixedColumns'), options = list(
                    pageLength = 20,
                    lengthMenu = c(10, 20, 30, 50),
                    colReorder = TRUE,
                    scrollX = TRUE,
                    fixedColumns = TRUE
                  )) %>%
      formatStyle(itemname[[1]], color = 'red', backgroupdColor = 'orange', fontWeight = 'bold') %>%
      formatStyle(names(probans1),
                  #                background = styleColorBar(probans1[[1]], 'lightblue'),
                  background = color_from_left(probans1[[1]], 'blue'),
                  backgroundSize = '100% 25%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'bottom') %>%
      formatStyle(names(diffans),
                  #                background = styleColorBar(diffans[[1]], 'lightgreen'),
                  background = color_from_middle(diffans[[1]], 'red', 'blue'),
                  backgroundSize = '100% 25%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'bottom') %>%
      formatStyle('z1',
                  #                background = styleColorBar(diffans[[1]], 'lightgreen'),
                  background = color_from_middle(scores$score.dat[nitem+3], 'red', 'blue'),
                  backgroundSize = '100% 25%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'bottom')
    
  })

### for widget(6) 'Ability Histogram'
  
  output$distPlot <- renderPlot({
    
    data <- v1$data
    result <- v2$data
    
    scores <- factor.scores(result, resp.pattern=data)
    nitem <- dim(data)[2]
    
    theta <- scores$score.dat[,nitem+3]
    
    # generate bins based on input$bins from ui.R
    
    bins <- seq(min(theta), max(theta), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(theta, breaks = bins, main="Histogram", xlab='Ability', col = 'darkgray', border = 'white', axes=T)
    box()
    
  })
  
})
