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
library(googlesheets4)
library(gargle)
library(bcrypt)

# remotes::install_github("rstudio/reactlog")
# library(reactlog)
# reactlog_enable()

# # designate project-specific cache
# options(gargle_oauth_cache = ".secrets")
# # check the value of the option, if you like
# gargle::gargle_oauth_cache()
# # trigger auth on purpose to store a token in the specified cache
# # a broswer will be opened
# googlesheets4::sheets_auth()
# sheets_auth(
#   cache = ".secrets",
#   email = "symonroth@gmail.com"
# )

dir("R", full.names = T) %>% purrr::walk(source)

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
        "Something great content"
      )
    )
  )
}

server <- function(input, output) {
  
  users <- reactive({ 
    # user_sheet <- "https://docs.google.com/spreadsheets/d/1l-lHBPO9_JaI5aAUyTQ0Dt6YYY7O2SzTYFLbAHjCxlg/edit?usp=sharing"
    # googlesheets4::read_sheet(user_sheet) %>% 
    dplyr::tibble(name = "admin", pw = bcrypt::hashpw("test")) %>% 
      dplyr::mutate(hash = purrr::map_chr(name, ~create_cookie(.x)))
  })
  
  user <- callModule(login_server, "user", users)

  observeEvent(user(), {
    observe(print(user()))
  })
}

shinyApp(ui, server)

# reactlog::reactlog_show()
