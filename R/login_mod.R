#' login_ui
#' @export
login_ui <- function(id, head = NULL, signin = T, recover = F, label_login = "User", label_pw = "Password"){
  ns <- NS(id)
  
  tagList(

    div(class="ui inverted page dimmer", id = ns("buffer"), #
        HTML('<div class="ui indeterminate text loader">Loading</div>')
    ),
    # class = "ui centered grid container",
    
    div(id = ns("checkin"), style = "margin-top: 125px;",
        div(class = "ui centered card", 
          div(class = "content",
            head,
            div(class="ui accordion", id = "checkin_options",
              div(class="active title", id = "default_title",
                HTML('<i class="dropdown icon"></i>'),
                "Login"
              ),
              div(class="active content", id = "default_content",
                div(class = "ui form",
                  div(class = "field",
                    label(label_login),
                    div(class="ui left icon input",
                        icon("user"),
                        shiny::tags$input(id = ns("username"), type = "text", value = "" , placeholder = label_login)
                    )
                  ),
                  div(class = "field",
                    label(label_pw),
                    div(class="ui left icon input",
                        icon("key"),
                        shiny::tags$input(id = ns("pw"), type = "password", value = "" , placeholder = label_pw)
                    )
                  ),
                  shiny::actionButton(inputId = ns("login"), label = "Login", class = "ui button", icon = icon("unlock alternate"))
                )
              ),
              if(signin){
                tagList(
                  div(class = "title",
                      HTML('<i class="dropdown icon"></i>'),
                      "Register"
                  ),
                  div(class = "content",
                     div(class = "ui form",
                        div(class = "field",
                            label("Username"),
                            div(class="ui left icon input",
                                icon("user"),
                                shiny::tags$input(id = ns("user"), type = "text", value="" , placeholder="Username")
                            )
                        ),
                        div(class = "field",
                            label("Secret"),
                            div(class="ui left icon input",
                                icon("key"),
                                shiny::tags$input(id = ns("pw1"), type="password", value="" , placeholder="Secret")
                            )
                        ),
                        div(class = "field",
                            label("Repeat your secret"),
                            div(class="ui left icon input",
                                icon("key"),
                                shiny::tags$input(id = ns("pw2"), type="password", value="" , placeholder="Secret")
                            )
                        ),
                        shiny::actionButton(inputId = ns("signin"), label = "Register", class = "ui button", icon = icon("sign in"))
                    )
                  )
                )
              },
              if(recover){
                tagList(
                  div(class = "title",
                      HTML('<i class="dropdown icon"></i>'),
                      "Forgot Password "
                  ),
                  div(class = "content",
                      div(class = "ui form",
                          div(class = "field",
                              label("Send an email to get new creds"),
                              div(class="ui left icon input",
                                  icon("envelop"),
                                  shiny::tags$input(id = ns("email"), type="text", value="" , placeholder="Username")
                              )
                          )
                      ),
                      br(),
                      shiny::actionButton(inputId = ns("recover"), label = "Recover", class = "ui button", icon = icon("undo alternate"))
                  )
                )
              }
            )
          ),
          uiOutput(ns("message"))
        )
      )
  )
}

#' checkin_feedback
#' @export
checkin_feedback <- function(msg = ""){
  if(msg == "") return(NULL)
  if(is.null(msg)) return(NULL)
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
login_server <- function(input, output, session, user_sheet){
  
  new <- reactive({ user$new(googlesheets4::read_sheet(user_sheet)) })
  
  observeEvent(input$login ,{
    shinyjs::addClass("buffer", "active")
    new()$login(input$username, input$pw)
    shinyjs::delay(1000, shinyjs::removeClass("buffer", "active"))
  })
  
  observeEvent(input$logout ,{
    
    shinyjs::addClass("buffer", "active")
    shinyjs::runjs("history.go(0);")
    # new()$logout()
    # new()$reset() 
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
    req(new())
    if(new()$session$status == 1) {
      # https://stackoverflow.com/questions/5033650/how-to-dynamically-remove-a-stylesheet-from-the-current-page/5033739
      shinyjs::delay(1000, 
        shinyjs::runjs('
          var sheet = document.getElementById("login-styles");
          sheet.disabled = true;
          sheet.parentNode.removeChild(sheet);
        ')
      )
      shinyjs::hide("checkin", anim = T, animType = "slide")
    } else {
      shinyjs::show("checkin") 
    }
  })
  
  # observe({ message(input$username) })
  # observe({ message(input$pw) })

  out <- eventReactive({input$login | input$signin}, {
    
    input$logout
    input$login
    input$signin
    input$recover
    
    input$password1
    input$password2
    input$username
    
    as.list(new()$session)
  })
  

  return(out)
}