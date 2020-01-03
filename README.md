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

ui <- dashboardPage(
  dashboardHeader(
    inverted = T,
    ### just add this to your ui
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
      "Something great"
    )
  )
)

server <- function(input, output) {
  
  ### User authentification
  user <- callModule(login_server, "user")
  ### User managment
  callModule(manager_server, "manager", user)
  ### Authorized UI
  output$authorized <- renderUI({ if(user()$status == 1) ui })
  # observe({ glimpse(user()) })

  ### Your Code
}

### call meta_ui instead of ui to initalize login screen
shinyApp(meta_ui(), server)
```

The app will start up with a login/sign in modal.

<img src = "demo.gif"> <!-- width = "80%" -->
