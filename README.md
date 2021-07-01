shinyuser
================

    ## ✓ Setting active project to '/Users/simonroth/Dropbox/trading/shinyuser'

[![](https://img.shields.io/github/languages/code-size/systats/shinyuser.svg)](https://github.com/systats/shinyuser)
[![](https://img.shields.io/github/last-commit/systats/shinyuser.svg)](https://github.com/systats/shinyuser/commits/master)
[![](https://img.shields.io/badge/lifecycle-experimental-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

This is a demonstration of how to implement user authentication directly
in a shiny app. The core idea is to provide a simple, secure and
modularized solution.

Features:

1.  User’s credentials are saved wherever you want.
2.  Clean and secure landing page.
3.  Stay logged in after refresh ([taken from
    calligross](https://gist.github.com/calligross/e779281b500eb93ee9e42e4d72448189)).
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
  })
  
}

shinyApp(ui, server)
```

<!-- <img src = "demo.gif"> <!-- width = "80%" -->
