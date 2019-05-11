openshiny
================

> Alpha version 0.0.0.1 (under active development)

This is a package for shiny apps that delivers

1.  user login/signin
2.  user managment/admin panel

Minimal Example of
`openshiny`

``` r
pacman::p_load(devtools, shiny, shiny.semantic, semantic.dashboard, tidyverse,
                RSQLite, dbplyr, shinyjs, shinytoastr)

# devtools::install_github("systats/openshiny)
library(openshiny)
check_user_db()

ui <- dashboardPage(
  dashboardHeader(
    inverted = T, 
    tagList(admin_ui("admin"), login_ui("login")) 
  ),
  dashboardSidebar(
    side = "left", size = "", inverted = T,
    sidebarMenu(
      div(class = "item",
        h4(class = "ui inverted header", "Something")
      ),
      div(class = "item",
        h4(class = "ui inverted header", "More of it")
      )
    )
  ),
  dashboardBody(
    div(class = "sixteen wide column",
      "Why not?"
    )
  )
)

server <- function(input, output) {
  
  ### This is neccessary for login and admin mod (do not chance)
  user <- callModule(login_server, "login") 
  callModule(admin_server, "admin", user) 
  
  # < ... Your Code ... >
}

shinyApp(ui, server)
```

The app will start up with a login/sign in modale.

<img src = "screen_login.png" width = "50%">
