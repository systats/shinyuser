#' entry_ui
#' @export
entry_ui <- function(.x){
  ns <- NS(.x$session_id) # pass session + user
  tagList(
    div(class = "ui form",
        div(class = "inline fields",
            div(class = "two wide field",
                simple_checkbox(ns("selected"), label = "", is_marked = F)
            ),
            div(class = "four wide field",
                shinyjs::disabled(shiny::textInput(ns("username"), "", placeholder = "Username",  value = .x$username))
            ),
            div(class = "four wide field",
                shinyjs::disabled(shiny::textInput(ns("password"), "", placeholder = "Password",  value = .x$password))
                #shiny::actionButton(inputId = ns("decrypt"), label = "", class = "ui compact icon button", icon = icon("eye")),
            ),
            div(class = "four wide field",
                dropdown(name = ns("role"), choices = c("admin", "client", "power-woman"), value = .x$role)
            ),
            div(class = "two wide field",
                shiny::actionButton(inputId = ns("edit"), label = "", class = "ui compact icon button", icon = icon("edit")),
                shinyjs::hidden(shiny::actionButton(inputId = ns("save"), label = "", class = "ui green compact icon button", icon = icon("save"))),
                shinyjs::hidden(shiny::actionButton(inputId = ns("remove"), label = "", class = "ui basic red compact icon button", icon = icon("trash")))
            )
        )     
    )
  )
}


#' entry_server
#' @export
entry_server <- function(input, output, session, data){
  
  # shinyjs::disable(id = "root") #id = "root-user"
  # shinyjs::enable("user")
  
  new <- user$new("data/users")
  
  
  observe({
    req(data)
    if(data$username == "NEW"){
      
      shinyjs::hide("edit")
      
      shinyjs::enable("username")
      shinyjs::enable("password")
      shinyjs::enable("role")
      shinyjs::enable(selector = ".dropdown")
      
      shinyjs::show("save", anim = T, animType = "fade")
      shinyjs::show("remove", anim = T, animType = "fade")
    }
  })
  
  observeEvent(input$edit, {
    
    shinyjs::hide("edit")
    
    shinyjs::enable("username")
    shinyjs::enable("password")
    shinyjs::enable("role")
    shinyjs::enable(selector = ".dropdown")
    
    shinyjs::delay(200, shinyjs::show("save", anim = T, animType = "fade"))
    shinyjs::delay(200, shinyjs::show("remove", anim = T, animType = "fade"))
  })
  
  
  observeEvent(input$save, {
    
    shinyjs::hide("save")
    shinyjs::hide("remove")
    
    shinyjs::disable("username")
    shinyjs::disable("password")
    shinyjs::disable("role")
    shinyjs::disable(selector = ".dropdown")
    
    shinyjs::show("edit", anim = T, animType = "fade")
    
    new$load(data$username)
    if(data$username != input$username) new$remove(prompt = F)
    new$reset()
    
    new$username <- input$username
    new$password <- input$password
    new$role <- input$role
    
    new$save()
    new$reset()
  })
  
  observeEvent(input$remove, {
    
    new <- user$new("data/users")
    new$username <- input$username
    
    new$remove(prompt = F)
    new$reset()
  })
}
