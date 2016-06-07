library(shiny)
library(ggplot2)

shinyServer(function(input, output) {
  
  # choose columns to display
  diamonds2 = iris
  
  output$mytable1 <- DT::renderDataTable({
    DT::datatable(diamonds2[,,drop=FALSE],
                  options = list(pageLength = 20, dom = 'tip'))
  })
  
  output$mytable2 <- DT::renderDataTable({
    print(str(input$show_vars))
    data <- iris[, input$show_vars]
    print(head(data))
    DT::datatable(diamonds2[, input$show_vars, drop = FALSE],
                  options = list(pageLength = 20, dom = 'tip'))
  })
  
})
