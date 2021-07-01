#' form_login
#' @export 
form_login <- function(id){
  ns <- NS(id)
  div(class = "ui form",
    div(class = "field",
      div(class = "ui left icon input", id = ns("frame_user"),
        HTML('<i class="ui user icon"></i>'),
        shiny::tags$input(id = ns("name"), type = "text", value = "" , placeholder = "Username")
      )
    ),
    div(class = "field",
      div(class = "ui left icon input", id = ns("frame_pw"),
        HTML('<i class="ui key icon"></i>'),
        shiny::tags$input(id = ns("pw"), type = "password", value = "" , placeholder = "Password")
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
        shiny::tags$input(id = ns("user"), type = "text", value="" , placeholder="name")
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
        shiny::tags$input(id = ns("email"), type = "text", value = "" , placeholder = "name")
      )
    ),
    div(class = "ui fluid button action-button", id = ns("recover"), HTML('<i class="ui undo alternate icon"></i>'))
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
login_ui <- function(id, head = NULL){
  
  ns <- NS(id)
  
  tagList(
    tags$head(
      tags$script(src = "https://cdn.jsdelivr.net/npm/js-cookie@2/src/js.cookie.min.js") 
    ),
    shinyjs::useShinyjs(),
    extendShinyjs(text = jsCode, functions = c("getcookie","setcookie","rmcookie")),
    div(class = "ui inverted active page dimmer", id = ns("buffer"),
      style = "background-color:#e0e1e2;",
      div(class="ui text loader", "Loading Data")
    ),
    hidden(
      div(class = "ui inverted active page dimmer", id = ns("checkin"), 
        style = "background-color:#e0e1e2;",
        div(class = "ui card", align = "left", #style = "margin-top: 10%;",
          div(class = "content",
            head,
            div(class="ui accordion", id = "checkin_options",
              div(class = "active title", id = "default_title",
                HTML('<i class="ui dropdown icon"></i>'),
                "Login"
              ),
              div(class="active content", id = "default_content",
                form_login(id)
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
  
  trial <- dplyr::filter(users, name == .user & pw == .pw)
  
  if(nrow(trial) == 1) {
    session <- dplyr::mutate(trial, status = 1)
  } else {
    session <- dplyr::tibble(user = .user, pw = .pw, status = 0)
  }
  return(session)
}

# https://gist.github.com/calligross/e779281b500eb93ee9e42e4d72448189
#' jsCode
#' @export 
jsCode <- '
  shinyjs.getcookie = function(params) {
    var cookie = Cookies.get("id");
    if (typeof cookie !== "undefined") {
      Shiny.onInputChange("user-jscookie", cookie);
    } else {
      var cookie = "";
      Shiny.onInputChange("user-jscookie", cookie);
    }
  }
  shinyjs.setcookie = function(params) {
    Cookies.set("id", escape(params), { expires: 0.5 });  
    Shiny.onInputChange("user-jscookie", params);
  }
  shinyjs.rmcookie = function(params) {
    Cookies.remove("id");
    Shiny.onInputChange("user-jscookie", "");
  }
'

#' login_server
#' @export
login_server <- function(input, output, session, users){
  
  sess <- reactive({
    req(users())
    js$getcookie()
    if(is.null(input$jscookie)) return(NULL)
    if(input$jscookie == ""){
      shinyjs::show("checkin")
      shinyjs::hide("buffer")
      check_credentials(users(), input$name, input$pw)
    } else {
      shinyjs::hide("buffer")
      dplyr::mutate(dplyr::filter(users(), name == input$jscookie), status = 1)
    }
  })
  
  
  observe({
    req(sess())
    print(input$jscookie)
  })
  
  observeEvent( input$logout ,{
    # reset session cookies
    js$rmcookie()
    # shinyjs::runjs("history.go(0);")
    # shinyjs::runjs("$('.dimmer').dimmer('show');")
  })

  observeEvent({  input$login }, {

    if(sess()$status == 1) {
      
      # set session cookie
      js$setcookie(sess()$name)
      # hide login panel
      shinyjs::hide("checkin")
      
    } else {
      # do some error shaling
      shinyjs::runjs("$('#user-checkin').transition('shake');")
    }
  }, ignoreInit = T)

  out <- eventReactive({ input$login }, {
    # only return data if valid login otherwise NULL
    if(sess()$status == 1) {
      return(sess())
    } else {
      return(NULL)
    }
  })

  return(out)
}
