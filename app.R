#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

source("trend_plot.R")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Apartment Temperature"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            # sliderInput("bins",
            #             "Number of bins:",
            #             min = 1,
            #             max = 50,
            #             value = 30),
            dateRangeInput("date_range",
                           "Dates:",
                           start = Sys.Date(),
                           end = Sys.Date())
        ),

        # Show a plot of the generated distribution
        mainPanel(
          textOutput("currentTemp"),
          plotOutput("tempTrend")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    # output$distPlot <- renderPlot({
    #   plot_temp()
    #   
    #     # # generate bins based on input$bins from ui.R
    #     # x    <- faithful[, 2]
    #     # bins <- seq(min(x), max(x), length.out = input$bins + 1)
    #     # 
    #     # # draw the histogram with the specified number of bins
    #     # hist(x, breaks = bins, col = 'darkgray', border = 'white',
    #     #      xlab = 'Waiting time to next eruption (in mins)',
    #     #      main = 'Histogram of waiting times')
    # })
    output$tempTrend <- renderPlot({
      plot_temp(input$date_range[1], input$date_range[2])
    })
    output$currentTemp <- renderText({
      temp_time = get_current_temp()
      paste0("Current Temperature: ", temp_time$temp, " (", temp_time$time, ")")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
