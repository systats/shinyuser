#' login_ui
#' @export
login_ui <- function(id){
  ns <- NS(id)
  tagList(

    div(class="ui inverted page dimmer", id = ns("buffer"), #
        HTML('<div class="ui text loader">Loading</div>')
    ),
    # class = "ui centered grid container",
    
    div(id = ns("checkin"), style = "margin-top: 125px;",
        div(class = "ui centered card", 
          div(class = "content",
            div(class="ui accordion", id = "checkin_options",
              div(class="active title", id = "default_title",
                HTML('<i class="dropdown icon"></i>'),
                "Login"
              ),
              div(class="active content", id = "default_content",
                div(class = "ui form",
                  div(class = "field",
                    label("User or Email"),
                    shiny::textInput(ns("username"), "", placeholder = "User",  value = "")
                  ),
                  div(class = "field",
                    label("Password"),
                    shiny::passwordInput(ns("pw"), "", placeholder = "Secret", value = "")
                  ),
                  shiny::actionButton(inputId = ns("login"), label = "Login", class = "ui primary button", icon = icon("unlock alternate"))
                )
              ),
              div(class = "title",
                  HTML('<i class="dropdown icon"></i>'),
                  "Register"
              ),
              div(class = "content",
                  div(class = "ui form",
                      # div(class = "field",
                      #     label("Email", icon("exclamation triangle")), 
                      #     shiny::textInput(ns("email"), "", placeholder = "Email", value = "")
                      # ),
                      div(class = "field",
                          label("Username"),
                          shiny::textInput(ns("user"), "", placeholder = "Username", value = "")
                      ),
                      div(class = "field",
                          label("Secret"),
                          shiny::passwordInput(ns("pw1"), "", placeholder = "Password", value = "")
                      ),
                      div(class = "field",
                          label("Repeat your secret"),
                          shiny::passwordInput(ns("pw2"), "", placeholder = "Password", value = "")
                      ),
                      shiny::actionButton(inputId = ns("signin"), label = "Register", class = "ui basic green button", icon = icon("sign in"))
                  )
              ),
              div(class = "title",
                  HTML('<i class="dropdown icon"></i>'),
                  "Forgot Password "
              ),
              div(class = "content",
                div(class = "ui form",
                    div(class = "field",
                        label("Send an email to get new creds"),
                        shiny::textInput(ns("recover_email"), "", placeholder = "Email", value = "")
                    )
                ),
                br(),
                shiny::actionButton(inputId = ns("recover"), label = "Recover", class = "ui secondary button", icon = icon("undo alternate"))
              )
            ),
            shiny::tags$script(
              "$(document).ready(function() {
                $('.ui.accordion')
                  .accordion();
                })"
            )
          ),
          uiOutput(ns("message"))
        )
      )
  )
}

#' checkin_feedback
#' @export
checkin_feedback <- function(msg){
  if(msg == "") return(NULL)
  header <- str_remove(msg, ":.*?$")
  content <- str_remove(msg, "^.*?: ")
  
  if(str_detect(msg, "Fail")){
    out <- tagList(
      div(class="ui attached icon warning message",
        HTML('<i class="close icon"></i>'),
        div(class="content",
          div(class="ui header",
            header
          ),
          content
        )
      )
    )
  } else if(str_detect(msg, "Success")){ 
    out <- tagList(
      div(class="ui attached icon positive message",
          HTML('<i class="close icon"></i>'),
          div(class="content",
              div(class="ui header",
                  header
              ),
              content
          )
      )
    )
  } else {
    out <- tagList(
      div(class="ui attached icon info message",
          HTML('<i class="close icon"></i>'),
          div(class="content",
              div(class="ui header",
                  header
              ),
              content
          )
      )
    )
  }
  
  tagList(
    out, 
    shiny::tags$script("$('.message .close')
      .on('click', function() {
        $(this)
          .closest('.message')
          .transition('fade')
        ;
      })
    ;")
  )
}

# log_logout_force <- function(usercon){
#   
#   shiny.stats::log_custom_action(
#     usercon, "user_log", 
#     values = list(
#       session = usercon$session_id, 
#       username = usercon$username, 
#       action = "logout"
#     )
#   )
#   ### !!! not active
#   #odbc::dbDisconnect(usercon$db_connection)
# }

#' login_server
#' @export
login_server <- function(input, output, session){
  
  new <- reactive({ user$new("data/users") })
  
  observeEvent(input$login ,{
    shinyjs::addClass("buffer", "active")
    new()$login(input$username, input$pw)
    shinyjs::delay(200, shinyjs::removeClass("buffer", "active"))
  })
  
  observeEvent(input$logout ,{
    
    shinyjs::addClass("buffer", "active")
    
    # shinyjs::removeClass(selector = "title", class = "active")
    # shinyjs::removeClass(selector = "content", class = "active")
    # shinyjs::addClass("default_title", class = "active")
    # shinyjs::addClass("default_content", class = "active")

    #log_logout_force(ucon())
    new()$logout()
    new()$reset() 
    shinyjs::delay(200, shinyjs::js$refresh())
  })
  
  observeEvent(input$recover, {
    new()$recover(input$recover_email)
  })
  
  observeEvent(input$signin ,{
    new()$register(input$user, input$pw1, input$pw2)
  })
  
  output$message <- renderUI({
    input$login
    input$logout
    input$signin
    input$recover
    checkin_feedback(new()$session$message)
  })
  
  observeEvent({input$login | input$signin | input$logout}, { 
    if(new()$session$status == 1) {
      shinyjs::hide("checkin") 
    } else {
      shinyjs::show("checkin") 
    }
  })
  
  ### initalize shiny.stats
  # creating user connection list and making sure required tables exist in DB
  # observeEvent(input$`user-logout`, { shiny.stats::log_action(ucon(), "logout") })
  
  out <- reactive({
    
    input$logout
    input$login
    input$signin
    input$recover
    
    input$password1
    input$password2
    input$username
    
    if(is.null(new()$session$status == 0)) return(as.list(new()$session))

    con <- odbc::dbConnect(RSQLite::SQLite(), dbname = "data/user_stats.sqlite")
    uc <- shiny.stats::initialize_connection(con, username = new()$session$username)
    shiny.stats::log_login(uc)
    shiny.stats::log_logout(uc)
    #shiny.stats::log_browser_version(input, uc)
    
    return(c(as.list(new()$session[-3]), uc))
  })
  
  return(out)
}