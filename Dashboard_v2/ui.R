
library(shinydashboard)

dashboardPage(

  dashboardHeader(title = "IRT Demonstration"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("File Selection", tabName="widget1", icon=icon("th")),
      menuItem("Data Selection", tabName="widget2", icon=icon("th")),
      menuItem("ICC Graph", tabName="widget3", icon=icon("th")),
      menuItem("Summary", tabName="widget4", icon=icon("th"))
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
                  tableOutput('contents')
                )
              )
      ),
      
      # Second tab content
      tabItem(tabName = "widget2",
              fluidRow(
                box(
                  uiOutput("selectChecks")
                )
              )
      ),
      
      # Third tab content
      tabItem(tabName = "widget3",
              fluidRow(
                box(
                  plotOutput("plot1", width=600, height=400)
                )
              )
      ),
      
      # Fourth tab content
      tabItem(tabName = "widget4",
              fluidRow(
                box(
                  verbatimTextOutput("summary")
                )
              )
      )
      
    )
  )
  
)