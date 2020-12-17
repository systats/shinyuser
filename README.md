shinyuser
================

[![](https://img.shields.io/github/languages/code-size/systats/shinyuser.svg)](https://github.com/systats/shinyuser)
[![](https://img.shields.io/github/last-commit/systats/shinyuser.svg)](https://github.com/systats/shinyuser/commits/master)
[![](https://img.shields.io/badge/lifecycle-experimental-blue.svg)](https://www.tidyverse.org/lifecycle/#experimental)

This is a demonstration of how to implement user authentication directly
in a shiny app. The core idea is to provide a simple, secure and
modularized solution.

Features:

1.  User’s credentials are saved as JSON file in `data/users`
2.  Easy to integrate with `shiny.info` in order to log user actions
3.  Build with
    [shiny.semantic](https://github.com/Appsilon/shiny.semantic) for
    clean design patterns
4.  R6 class user management
5.  Admin panel to edit user data
6.  Tested with shinyapps.io

Minimal example of
`shinyuser`

``` r
pacman::p_load(devtools, shiny, shiny.semantic, semantic.dashboard, tidyverse,
                RSQLite, shinyjs, R6)

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

  ### call all your modules only if a user is successfully logged in
  observeEvent(user(), {
    observe(print(user()))
    callModule(manager_server, "manager", user)
    callModule(admin_server, "admin", users)
  })
  
}

shinyApp(ui, server)
```

The app will start up with a login/sign in modal.

<img src = "demo.gif"> <!-- width = "80%" -->
