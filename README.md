shinyuser
================

[![](https://img.shields.io/github/languages/code-size/systats/shinyuser.svg)](https://github.com/systats/shinyuser)
[![](https://img.shields.io/github/last-commit/systats/shinyuser.svg)](https://github.com/systats/shinyuser/commits/master)
[![](https://img.shields.io/badge/lifecycle-experimental-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

This is a demonstration of how to implement user authentication directly
in a shiny app. The core idea is to provide a simple, secure and
modularized solution.

Features:

1.  User’s credentials are saved wherever you want.
2.  Clean landing page that overlays any arbitrary layout
3.  Increasing security features
    -   delayed login trialing (5 sec)
    -   `openssl` for daily session cookies
    -   `bcrypt` for password encrypton
4.  Stay logged in after refresh ([taken from
    calligross](https://gist.github.com/calligross/e779281b500eb93ee9e42e4d72448189)).
5.  Build with
    [shiny.semantic](https://github.com/Appsilon/shiny.semantic) for
    clean design patterns
6.  Tested with shinyapps.io

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
    dplyr::tibble(name = "admin", pw = bcrypt::hashpw("test")) %>% 
      ### use the user name and hashed password to create a 24h session cookie
      dplyr::mutate(hash = purrr::map2_chr(name, pw, ~create_cookie(.x, .y)))
  })
  
  user <- callModule(login_server, "user", users)

  observeEvent(user(), {
    observe(print(user()))
  })
}

shinyApp(ui, server)
```

<!-- <img src = "demo.gif"> <!-- width = "80%" -->
