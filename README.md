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
# options(shiny.maxRequestSize=200*1024^2) 

### Needed for user db initialization
check_user_db()

### UI
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

### Server
server <- function(input, output) {
  
  ### This is neccessary for login and admin mod (do not chance)
  users <- reactive({
    user()
    con <- dbConnect(SQLite(), "data/user.db")
    out <- con %>% 
      tbl("users") %>% 
      as_tibble
    dbDisconnect(con)
    return(out)
  })
  
  user <- callModule(login_server, "login", users) 
  callModule(admin_server, "admin", users, user) 
  ### End 
  
  # < ... Your Code ... >
  
  
}

### Main
shinyApp(ui, server)
```
