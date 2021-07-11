library(tidyverse)
library(shiny)
library(shinyjs)
library(shiny.semantic)
library(semantic.dashboard)
library(shinyuser)

ui <- function(){
  dashboardPage(
    dashboardHeader(
      inverted = T,
      login_ui("user"),
      div(class = "ui button action-button", id = "user-logout", 
          icon("power off")
      )
    ),
    dashboardSidebar(
      side = "left", size = "", inverted = T,
      sidebarMenu(
        div(class = "item",
            h4(class = "ui inverted header", "Something")
        )
      )
    ),
    dashboardBody(
      div(class = "sixteen wide column",
        "Some secret content"
      )
    )
  )
}

server <- function(input, output) {
  
  users <- reactive({ 
    tibble(name = "admin", pw  = "test")
  })
  
  user <- callModule(login_server, "user", users)
  
  observeEvent(user(), {
    observe(print(user()))
    # ... put your modules here
  }, ignoreInit = T)
  
}

shinyApp(ui, server)
