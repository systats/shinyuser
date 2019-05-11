#' @export
login_form <- function(session){
  tagList(
      div(class="content",
          h1(class="ui inverted header",
             "Please login in"
          ),
          tags$form(class="ui small form",
                    div(class="field",
                        textInput(session$ns("user"), NULL, placeholder = "Username or Email")
                    ),
                    div(class="field",
                        passwordInput(session$ns("pw"), NULL, placeholder = "Password")
                    ),
                    actionButton(session$ns("login"), class = "ui fluid primary submit button", label = "Log in"),
                    actionButton(session$ns("change_to_signin"), class = "ui fluid secondary submit button", label = "Sign in")
          )
      )
  )
}
#' @export
signin_form <- function(session){
  tagList(
    #div(class="ui active page dimmer",
        div(class="content",
            h1(class="ui inverted header",
               "Please sign in"
            ),
            tags$form(class="ui samll form",
                      div(class="field",
                          textInput(session$ns("user"), NULL, placeholder = "Username or Email")
                      ),
                      div(class="field",
                          passwordInput(session$ns("pw_1"), NULL, placeholder = "Password")
                      ),
                      div(class="field",
                          passwordInput(session$ns("pw_2"), NULL, placeholder = "Verify Password")
                      ),
                      actionButton(session$ns("signin"), class = "ui fluid secondary submit button", label = "Sign in"),
                      actionButton(session$ns("change_to_login"), class = "ui fluid primary submit button", label = "Log in")
            )
        )
    )
  #)
}

#' @export
login_ui <- function(id){
  ns <- NS(id)
  tagList(
    shinytoastr::useToastr(),
    shinyjs::useShinyjs(),
    div(class="ui active page dimmer", id = ns("login_dimmer"), #
      HTML('<div class="ui text loader">Loading</div>')
    ),
    uiOutput(ns("login_modal")),
    actionButton(ns("logout"), class = "circular ui red icon button", label = "", icon = icon("sign out"))
  )
}

# $("")(function() {
#   $(".ui.dimmer").dimmer("toggle");
# });

#' @export
login_server = function(input, output, session){
  
  log <- reactiveValues(
    state = "login", #login
    password = "", 
    user = ""
  )
  
  observeEvent(input$logout ,{
    log$state <- "login"
  })
  
  observeEvent(input$signin ,{
    log$state <- "signin"
  })
  
  observeEvent(input$change_to_login, {
    log$state <- "login"
  })
  
  observeEvent(input$change_to_signin, {
    log$state <- "signin"
  })
  
  users <- reactive({
    log$state
    
    con <- dbConnect(SQLite(), "data/user.db") # Creates database file test.db
    out <- con %>%
      tbl("users")  %>%
      as_tibble
    
    dbDisconnect(con)
    return(out)
  })
  
  user <- reactive({
    input$signin
    users() %>% 
      dplyr::filter(
        user == input$user, 
        password == input$pw
      )
  })
  
  observeEvent(input$login ,{
    
    if(nrow(user()) == 1) {
      
      toastr_success("Successfully logged in.")
      
      user_event <- tibble(
        user = input$user,
        time = Sys.time(),
        event = "login_in"
      )
      
      con <- dbConnect(SQLite(), "data/user.db") # Creates database file test.db
      dbWriteTable(con, "events", user_event, append = T)
      dbDisconnect(con)
      
      log$state <- "verified"
      log$user <- input$user
      log$pw <- input$pw
      log$role <- user()$role
      
      toastr_info(glue::glue("Hi {user()$user}- welcome back!"))
      
    } else {
      toastr_error("Username or password incorrect.")
    }
  })
  
  
  observeEvent(input$signin, {
    
    user_names <- users() %>%
      dplyr::pull(user)
    
    if(any(user_names %in% input$user)){
      toastr_error("Username already taken.")
      return(NULL)
    }
    
    if(input$pw_1 == "") {
      toastr_error("No password provided.")
      return(NULL)
    }
    
    if(input$pw_1 != input$pw_2) {
      toastr_error("Passwords do not match.")
      # stop here: not_matching_passwords
      return(NULL)
    }
    
    toastr_success("Successfully signed in.")
    
    user_profile <- tibble(
      user = input$user,
      password = input$pw_1,
      signed_in = Sys.time(),
      role = "user"
    )
    
    con <- dbConnect(SQLite(), "data/user.db") # Creates database file test.db
    dbWriteTable(con, "users", user_profile, append = T)
    dbDisconnect(con)
    
    log$state <- "verified"
    log$user <- input$user
    log$pw <- input$pw_1
    log$role <- "user"
  })
  
  ### Main Output
  output$login_modal <- renderUI({
    
    if(log$state == "verified"){
      #shinyjs::runjs("$('.dimmer').dimmer('hide');")
      #hinyjs::removeClass("login_dimmer", "active")
      return("")
    } else if(log$state == "signin"){
      #shinyjs::runjs("$('.dimmer').dimmer('show');")
      #shinyjs::addClass("login_dimmer", "active")
      #shinyjs::show("login_dimmer")
      div(class="ui page dimmer active",
        signin_form(session)
      )
    } else {
      #shinyjs::show("login_dimmer")
      #shinyjs::addClass("login_dimmer", "active")
      div(class="ui page dimmer active",
        login_form(session)
      )
    } 
    
  })
  
  
  observe({
    shinyjs::delay(1, shinyjs::hide("login_dimmer"))
  })

  out <- eventReactive(log$state,{
    if(log$state == "verified"){
      return(log)
    } else {
      return(NULL)
    }
  })
  
  return(out)
}