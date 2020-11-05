# devtools::document()
# devtools::install()

library(dplyr)
library(stringr)
library(purrr)
library(jsonlite)
library(R6)
library(shiny.semantic)
library(shiny)
library(shinyjs)
library(semantic.dashboard)
library(RSQLite)

# library(googlesheets4)
# install.packages("V8")
# library(V8)
# devtools::install_github("Appsilon/shiny.info")
# library(shiny.info)
# devtools::install_github("systats/shinyuser")
# library(shinyuser)
# devtools::load_all()

dir("R", full.names = T) %>% purrr::walk(source)

ui <- function(){
  dashboardPage(
    dashboardHeader(
      inverted = T,
      login_ui("user", signin = F)
      # manager_ui("manager")
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
        #"Something great content",
        admin_ui("admin")
      )
    )
  )
}

### Initalize root user
# con <-  RSQLite::dbConnect(RSQLite::SQLite(), "data/users.db") 
# df <- tibble(username = "root", password = "test", role = "admin")
# RSQLite::dbWriteTable(con, "users", df)

server <- function(input, output) {
  
  ### Goofle sheets User authentification
  # at top: sheets_deauth()
  # at top: sheets_auth()
  # user_sheet <- "https://docs.google.com/spreadsheets/d/1ZbSSxaMuf0fV5_2exz69ahOMZH46bNwlkXSKyOjYD5w/edit?usp=sharing"
  # users <- reactive({ googlesheets4::read_sheet(user_sheet) })
  
  users <- reactive({ 
    con <-  RSQLite::dbConnect(RSQLite::SQLite(), "data/users.db") 
    con %>% 
      dplyr::tbl("users") %>% 
      as_tibble()
  })
  
  user <- callModule(login_server, "user", users)

  observeEvent(user(), {
    observe(print(user()))
    callModule(manager_server, "manager", user)
    callModule(admin_server, "admin", users)
  })
  
}

shinyApp(ui, server)
