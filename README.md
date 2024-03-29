shinyuser
================

This is a demonstration of how to implement user authentication directly
in a shiny app. The core idea is to provide a simple, secure and
modularized solution.

Features:

1.  User’s credentials are saved wherever you want.
2.  Clean landing page that overlays any arbitrary layout
3.  Basic security features
    -   delayed login trialing (5 sec)
        <!-- + `openssl` for daily session cookies -->
    -   `bcrypt` for password encrypton
        <!-- 3. Stay logged in after refresh ([taken from calligross](https://gist.github.com/calligross/e779281b500eb93ee9e42e4d72448189)). -->
4.  Build with
    [shiny.semantic](https://github.com/Appsilon/shiny.semantic) for
    clean design patterns
5.  Tested with shinyapps.io

Minimal example of `shinyuser`

``` r
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
      login_ui("user"),
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
    dplyr::tibble(name = "admin", pw = bcrypt::hashpw("test"))
  })
  
  user <- callModule(login_server, "user", users)

  observeEvent(user(), {
    observe(print(user()))
  })
}

shinyApp(ui, server)
```

<!-- <img src = "demo.gif"> <!-- width = "80%" -->
