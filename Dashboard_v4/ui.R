
library(shinydashboard)
require(rCharts)
require(DT)

dashboardPage(
  
  dashboardHeader(title = "IRT Demonstration"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Data Selection", tabName="widget1", icon=icon("th")),
      menuItem("Item Selection", tabName="widget2", icon=icon("th")),
      menuItem("ICC and Summary", tabName="widget3", icon=icon("th")),
      menuItem("ICC (Highcharts)", tabName="widget4", icon=icon("th")),
      menuItem("Data Table", tabName="widget5", icon=icon("th")),
      menuItem("Histogram of Ability", tabName = "widgets6", icon = icon("th"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "widget1",
              fluidRow(
                box(
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
                               '"')
                ),
                box(
                  tableOutput('contents_w1')
                )
              )
      ),
      
      # Second tab content
      tabItem(tabName = "widget2",
              fluidRow(
                box(
                  uiOutput("selectChecks"),
                  actionButton("do", "Set")
                ),
                box(
                  tableOutput('contents_w2')
                )
              )
      ),
      
      # Third tab content
      tabItem(tabName = "widget3",
              fluidRow(
                plotOutput("plot1", width=600, height=400),
                box(
                  verbatimTextOutput("summary")
                )
              )
      ),
      
      # Fourth tab content
      tabItem(tabName = "widget4",
              fluidRow(
                showOutput("myChart", "highcharts")
              )
      ),
      
      # Fifth tab content
      tabItem(tabName = "widget5",
              fluidRow(
                title = 'Example of DataTable',
                tabPanel('DataTable1', DT::dataTableOutput('mytable1'))
              )
      ),
      
      # Sixth tab content
      tabItem(tabName = "widgets6",
              fluidPage(
                title = 'Histogram of Ability',
                box(
                  sliderInput("bins",
                              "Number of bins:",
                              min = 1,
                              max = 50,
                              value = 30)
                ),
                box(
                  plotOutput("distPlot")
                )
              )
      )
      
    )
  )
  
)