#' form_login
#' @export 
form_login <- function(id, label_user, label_pw){
  ns <- NS(id)
  div(class = "ui form",
    div(class = "field",
      h3(label_user),
      div(class = "ui left icon input", id = ns("frame_user"),
        HTML('<i class="ui user icon"></i>'),
        shiny::tags$input(id = ns("username"), type = "text", value = "" , placeholder = label_user)
      )
    ),
    div(class = "field",
      h3(label_pw),
      div(class = "ui left icon input", id = ns("frame_pw"),
        HTML('<i class="ui key icon"></i>'),
        shiny::tags$input(id = ns("pw"), type = "password", value = "" , placeholder = label_pw)
      )
    ),
    div(class = "ui fluid button action-button", id = ns("login"), HTML('<i class="ui unlock alternate icon"></i>'))
  )
}

#' form_signin
#' @export 
form_signin <- function(id){
  ns <- NS(id)
  div(class = "ui form",
    div(class = "field",
      div(class = "ui left icon input",
        HTML('<i class="ui user icon"></i>'),
        shiny::tags$input(id = ns("user"), type = "text", value="" , placeholder="Username")
      )
    ),
    div(class = "field",
      div(class = "ui left icon input",
        HTML('<i class="ui key icon"></i>'),
        shiny::tags$input(id = ns("pw1"), type = "password", value = "" , placeholder = "Secret")
      )
    ),
    div(class = "field",
      div(class = "ui left icon input",
        HTML('<i class="ui key icon"></i>'),
        shiny::tags$input(id = ns("pw2"), type = "password", value = "" , placeholder = "Secret")
      )
    ),
    div(class = "ui fluid button action-button", id = ns("signin"), HTML('<i class="ui sign in icon"></i>'))
  )
}

#' form_recover
#' @export 
form_recover <- function(id){
  ns <- NS(id)
  div(class = "ui form",
    div(class = "field",
      label("Send an email to get new creds"),
      div(class="ui left icon input",
        HTML('<i class="ui envelop icon"></i>'),
        shiny::tags$input(id = ns("email"), type = "text", value = "" , placeholder = "Username")
      )
    ),
    div(class = "ui fluid button action-button", id = ns("recover"), HTML('<i class="ui undo alternate icon"></i>'))
  )
}


clickjs <- '$(document).keyup(function(event) {
    if (event.key == "Enter") {
        $("#user-login").click();
    }
});'

#' login_ui
#' @export 
login_ui <- function(id, head = NULL, signin = T, recover = F, label_user = "User", label_pw = "Password"){
  
  ns <- NS(id)
  
  tagList(
    shinyjs::useShinyjs(),
    div(class = "ui inverted active page dimmer",  style = "background-color:#e0e1e2;",
      div(class = "ui card", align = "left", id = ns("checkin"), #style = "margin-top: 10%;",
        div(class = "content",
          head,
          div(class="ui accordion", id = "checkin_options",
            div(class = "active title", id = "default_title",
              HTML('<i class="ui dropdown icon"></i>'),
              "Login"
            ),
            div(class="active content", id = "default_content",
              form_login(id, label_user, label_pw)
            ),
            if(signin){
              tagList(
                div(class = "title",
                  HTML('<i class="ui dropdown icon"></i>'),
                  "Register"
                ),
                div(class = "content",
                  form_signin(id)
                )
              )
            },
            if(recover){
              tagList(
                div(class = "title",
                  HTML('<i class="ui dropdown icon"></i>'),
                  "Forgot Password "
                ),
                div(class = "content",
                  form_recover(id)
                )
              )
            }
          )
        )
      ),
      shinyjs::hidden(
        div(id = ns("checkmark"),
          login_annimation()
        )
      )
      #uiOutput(ns("message"))
    ),
    shiny::tags$script("$('.dimmer').dimmer({closable: false}).dimmer('show');"),
    shiny::tags$script("$('.ui.accordion').accordion();"),
    # https://stackoverflow.com/questions/32335951/using-enter-key-with-action-button-in-r-shiny
    shiny::tags$script(clickjs)
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

#' login_server
#' @export
login_server <- function(input, output, session, users){
  
  new <- reactive({
    user$new(users()) 
  })
  
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
  
  # output$message <- renderUI({
  #   input$login
  #   input$logout
  #   input$signin
  #   input$recover
  #   checkin_feedback(new()$session$message)
  # })
  
  observeEvent({input$login | input$signin | input$logout}, { 
    # req(new())
    if(new()$session$status == 1) {
      
      shinyjs::show("checkmark")
      shinyjs::hide("checkin")
      shinyjs::delay(1400, shinyjs::runjs("$('#user-checkmark').dimmer({transition: 'vertical flip'}).dimmer('hide');"))
      shinyjs::delay(1500, shinyjs::runjs("$('.dimmer').dimmer('hide');"))
      
    } else {
      
      shinyjs::addCssClass("frame_user", "error")
      shinyjs::addCssClass("frame_pw", "error")
      shinyjs::runjs("$('#user-checkin').transition('shake');")
      shinyjs::delay(2000, shinyjs::removeCssClass("frame_user", "error"))
      shinyjs::delay(2000, shinyjs::removeCssClass("frame_pw", "error"))
    
    }
  }, ignoreInit = T)

  out <- eventReactive({input$login | input$signin}, {
    
    if(new()$session$status == 1) {
      return(as.list(new()$session))
    } else {
      return(NULL)
    }
  })

  return(out)
}