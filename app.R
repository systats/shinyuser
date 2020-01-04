# devtools::document()
# devtools::install()

library(shiny)
library(shiny.semantic)
library(shinyjs)
library(semantic.dashboard)
library(dplyr)
library(stringr)
library(purrr)
library(jsonlite)
library(R6)
library(RSQLite)
# install.packages("V8")
library(V8)
# devtools::install_github("Appsilon/shiny.info")
# library(shiny.info)
# devtools::install_github("systats/shinyuser")
# library(shinyuser)
# devtools::load_all()

dir("R", full.names = T) %>% walk(source)

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
  
  ### User authentification
  user <- callModule(login_server, "user")
  ### User managment
  callModule(manager_server, "manager", user)
  ### Authorized content
  output$authorized <- renderUI({ if(user()$status == 0) ui })
  # observe({ glimpse(user()) })
  
  # uc <- reactive({
  #   req(user())
  #   ### initalize shiny.stats
  #   # creating user connection list and making sure required tables exist in DB
  #   # observeEvent(input$`user-logout`, { shiny.stats::log_action(ucon(), "logout") })
  #   con <- odbc::dbConnect(RSQLite::SQLite(), dbname = "data/user_stats.sqlite")
  #   uc <- shiny.stats::initialize_connection(con, username = user()$username)
  #   shiny.stats::log_login(uc)
  #   shiny.stats::log_logout(uc)
  #   shiny.stats::log_browser_version(input, uc)
  #   uc
  # })
  
  # ....
  
}


shinyApp(meta_ui(), server)
