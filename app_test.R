library(tidyverse)
library(shiny)
library(shinyjs)
library(shiny.semantic)
library(semantic.dashboard)
library(shinyuser)
library(openssl)
library(bcrypt)

ui <- function(){
  dashboardPage(
    dashboardHeader(
      inverted = T,
      shinyuser::login_ui("user", test = T),
      div(class = "ui circular icon button action-button", id = "user-logout", 
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
          "Something great content"
      )
    )
  )
}

server <- function(input, output) {
  
  users <- reactive({ 
    dplyr::tibble(name = "admin", email = name, pw = bcrypt::hashpw("test"))
  })
  
  user <- callModule(shinyuser::login_server, "user", users)
  
  observeEvent(user(), {
    observe(print(user()))
  })
}


shinyApp(ui, server)