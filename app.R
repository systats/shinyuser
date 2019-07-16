devtools::load_all()
#devtools::document()

pacman::p_load(devtools, shiny, shiny.semantic, semantic.dashboard, tidyverse, DT,
                RSQLite, dbplyr, R6, shinyjs, shinytoastr)

# library(shinyuser)
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
  user <- callModule(login_server, "login") 
  callModule(admin_server, "admin", user) 
  
  # < ... Your Code ... >
  
}

### Main
shinyApp(ui, server)