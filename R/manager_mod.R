#' manager_ui
#' @export
manager_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput(ns("options")),
    admin_ui(ns("admin"))
  )
}

#' manager_server
#' @export
manager_server <- function(input, output, session, user){
  
  output$options <- renderUI({
    req(user())
    dropdownMenu(
      type = "notifications", 
      icon = icon("user"), 
      show_counter = F,
      div(class = "item", style = "min-width: 150px;",
          theme_ui(session$ns("theme"))
      ),
      div(class = "action-button item", style = "min-width: 150px;", id = "account",
          icon("user"), "Your Account"
      ),
      if(user()$role == "admin"){
        list(
          div(class = "action-button item", style = "min-width: 150px;", id = "manager-admin-show",
              icon("cogs"), "Admin Panel"
          ),
          div(class="ui divider"),
          ### this triggers the logout inside login_mod
          div(class = "action-button item", style = "min-width: 150px;", id = "user-logout", 
              icon("power off"), "Logout"
          )
        )
      } else {
        ### this triggers the logout inside login_mod
        div(class = "action-button item", style = "min-width: 150px;", id = "user-logout", 
            icon("power off"), "Logout"
        )
      }
    )
  })
  
  callModule(admin_server, "admin", user)
  callModule(theme_server, "theme")
}