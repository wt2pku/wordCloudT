library(shiny)
library(shinyIncubator)

shinyUI(fluidPage(
  progressInit(),
  
  # Application title
  headerPanel("Word Cloud For Twitters"),
  
  # Sidebar with a slider and selection inputs
  sidebarPanel(width = 5,
               textInput("selection", "Input a keyword, then hit 'Change' Button:", 
                           "dataScience"),
               actionButton("update", "Change"),
               hr(),
               h4("You can manipulate word cloud here:"),
               sliderInput("freq", 
                           "Minimum Frequency:", 
                           min = 1,  max = 50, value = 5),
               sliderInput("max", 
                           "Maximum Number of Words:", 
                           min = 1,  max = 300,  value = 50)
  ),
  
  # Show Word Cloud
  mainPanel(
    h3('Word cloud of 1000 Twitters for the keyword you entered (You need to wait about 30s to update):'),
    h4('If little Tweets for a keyword, there will be an Error'),
    plotOutput("plot")
  )
))