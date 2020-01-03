rm(list = ls())
# rm(list = ls())
library(shiny)
library(shiny.semantic)
library(semantic.dashboard)
library(dplyr)
library(stringr)
library(purrr)
library(jsonlite)
library(R6)
# devtools::install_github("systats/shinyuser")
library(shinyuser)
# devtools::install_github("Appsilon/shiny.info")
library(shiny.info)

# devtools::document()
# devtools::load_all()

ui <- dashboardPage(
  dashboardHeader(
    inverted = T,
    manager_ui("manager")
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

server <- function(input, output) {
  
  user <- callModule(login_server, "user")
  callModule(manager_server, "manager", user)
  
  output$main <- renderUI({
    if(user()$status == 1){
      ui
    }
  })
  
  observe({
    glimpse(user())
  })

  # ....

  
}


shinyApp(meta_ui(), server)
