#' form_login
#' @export 
form_login <- function(id, test){
  ns <- NS(id)
  div(class = "ui form",
    div(class = "field",
      div(class = "ui left icon input", id = ns("frame_user"),
        HTML('<i class="ui user icon"></i>'),
        shiny::tags$input(id = ns("name"), type = "text", value = ifelse(test, "admin", "") , placeholder = "Username or Email")
      )
    ),
    div(class = "field",
      div(class = "ui left icon input", id = ns("frame_pw"),
        HTML('<i class="ui key icon"></i>'),
        shiny::tags$input(id = ns("pw"), type = "password", value = ifelse(test, "test", "") , placeholder = "Password")
      )
    ),
    div(class = "ui fluid button action-button", id = ns("login"), HTML('<i class="ui unlock alternate icon"></i>'))
  )
}

#' clickjs
#' @export 
clickjs <- '$(document).keyup(function(event) {
    if (event.key == "Enter") {
        $("#user-login").click();
    }
});'


#' login_ui
#' @export 
login_ui <- function(id, head = NULL, tail = NULL, test = F){
  
  ns <- NS(id)
  
  tagList(
    tags$head(
      tags$script(src = "https://cdn.jsdelivr.net/npm/js-cookie@2/src/js.cookie.min.js") 
    ),
    shinyjs::useShinyjs(),
    extendShinyjs(text = js_cookies, functions = c("getcookie","setcookie","rmcookie")),
    div(class = "ui inverted active page dimmer", id = ns("buffer"),
      style = "background-color:#e0e1e2;",
      div(class="ui text loader", "Loading Data")
    ),
    hidden(
      div(class = "ui inverted active page dimmer", id = ns("checkin"), 
        style = "background-color:#e0e1e2;",
        div(class = "ui card", align = "left", style = "width:400px;",
          div(class = "content",
            head,
            div(class="ui accordion", id = "checkin_options",
              div(class = "active title", id = "default_title",
                HTML('<i class="ui dropdown icon"></i>'),
                "Login"
              ),
              div(class="active content", id = "default_content",
                form_login(id, test = test)
              ),
              
              div(class = "title", id = "title2",
                  HTML('<i class="ui dropdown icon"></i>'),
                  "Forgot your password?"
              ),
              div(class="content", id = "content2",
                 recovery_ui(ns("recovery"))
              )
            )
          )
        )
      )
    ),
    shiny::tags$script("$('.ui.accordion').accordion();"),
    # https://stackoverflow.com/questions/32335951/using-enter-key-with-action-button-in-r-shiny
    shiny::tags$script(clickjs)
  )
}

#' check_credentials
#' @export 
check_credentials <- function(users, .user, .pw){
  
  trial <- dplyr::filter(users, name == .user & pw == bcrypt::hashpw(.pw, pw))
  

  if(nrow(trial) == 1) {
    session <- dplyr::mutate(trial, status = 1)
  } else {
    session <- NULL
  }
  return(session)
}

#' login_server
#' @export
login_server <- function(input, output, session, users, delay = 5){
  
  callModule(recovery_server, "recovery")
  
  observe({
    shinyjs::show("buffer")
    shinyjs::show("checkin")
  })
  
  user <- eventReactive(input$login, {
    req(users())
    
    known <- dplyr::mutate(dplyr::filter(users(), 
                                         (name == input$name | email == input$name), 
                                         bcrypt::checkpw(password = input$pw, hash = pw)), 
                           status = 1)

    
    glimpse(known)

    if(nrow(known) == 0){
      shinyjs::addCssClass("login", "disabled")
      shinyjs::delay(5000, shinyjs::removeCssClass("login", "disabled"))
      shinyjs::runjs("$('#user-checkin').transition('shake');")
      return(NULL)
    }
    
    shinyjs::hide("checkin")
    shinyjs::hide("buffer")
    
    return(known)
  })
  
  
  observeEvent( input$logout ,{
    print(glue::glue("Logged out"))
    shinyjs::runjs("history.go(0);")
  })


  return(user)
}
