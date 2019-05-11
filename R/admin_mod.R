#' admin_ui
#' @export
admin_ui = function(id){
  ns <- NS(id)
  tagList(
    uiOutput(ns("admin_modal")),
    uiOutput(ns("admin_options"))
  )
}

#' @export
admin_server = function(input, output, session, users, user){
  
  log = reactiveValues(state = "")

  observeEvent(input$admin ,{
    log$state <- "admin"
  })
  
  observeEvent(input$back ,{
    log$state <- ""
  })
  
  output$admin_options <- renderUI({
    req(user())
    if(user()$role == "admin"){
      actionButton(session$ns("admin"), class = "circular ui icon button", label = "", icon = icon("user"))
    } else {
      ""
    }
  })
  
  output$admin_modal <- renderUI({
    if(log$state == "admin"){
      tagList(
        shiny::tags$style("#admin_dimmer{overflow-y:scroll;}"),
        div(class="ui active page dimmer", id = "admin_dimmer",
            div(class = "content", align = "left", style = "width: 80%; min-height: 100vh;",
                div(class = "ui inverted segment",
                    actionButton(session$ns("back"), class = "ui right floated basic inverted circular icon button", label = "", icon = icon("remove")), 
                    span(class = "ui header",
                         "Admin Panel"
                    ),
                    tabset(
                      tabs = list(
                        list(
                          menu = "User Table",
                          content = manage_user_ui(session$ns("user_tab"))
                        ),
                        list(
                          menu = "Stats", 
                          content = "1"
                        ),
                        list(
                          menu = "Event Table",
                          content = "" 
                        )
                      )
                    )
                )
            )
        )
      )
    } else {
      return("")
    }
  })
  
  callModule(manage_user_server, "user_tab")
  
}