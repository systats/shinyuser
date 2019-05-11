#' @export
sql_delete_row = function(con, tbl, var, value){
  query <- glue::glue(
    "DELETE FROM {tbl}
WHERE {var} = '{value}'", 
    .con = con
  )
  dbExecute(con, query)
  return(con)
}

#' @export
user_validation = function(session, question){
  tagList(
    div(class="ui active page dimmer",
        div(class = "content",
            div(class="ui icon header",
                icon("archive icon"),
                question
            ),
            div(class="content",
                div(class="actions",
                    actionButton(session$ns("remove_user_deny"), class = "ui red basic cancel inverted button", label = "No",  icon = icon("remove")),
                    actionButton(session$ns("remove_user_approve"), class = "ui green ok inverted button", label = "Yes",  icon = icon("checkmark"))
                )
            )
        )
    )
  )
}

#' @export
user_table_entry = function(.x, session){
  tagList(
    div(class = "fields",
        div(class = "three wide field",
          .x$user
        ),
        div(class = "three wide field",
          .x$password
        ),
        div(class = "one wide field",
          actionButton(session$ns("{.x$user}_unhash"), class = "ui icon button", label = "",  icon = icon("eye"))
        ),
        div(class = "two wide field",
          shiny.semantic::dropdown(session$ns(glue::glue("{.x$user}_role")), choices = c("admin", "user"), value = .x$role)
        ),
        div(class = "seven wide field"),
        div(class = "one wide field",
          actionButton(session$ns(glue::glue("{.x$user}_remove")), class = "ui basic red icon button", label = "",  icon = icon("remove user"))
        )
    )
  )
}

#' @export
add_user_table_entry = function(session){
  tagList(
    div(class = "fields",
        div(class = "three wide field",
            textInput(session$ns("new_user"), NULL, placeholder = "Username or Email")
        ),
        div(class = "three wide field",
            textInput(session$ns("new_pw"), NULL, placeholder = "Password")
        ),
        div(class = "two wide field",
            shiny.semantic::dropdown(session$ns(glue::glue("new_role")), choices = c("admin", "user"), value = "user")
        ),
        div(class = "seven wide field"),
        div(class = "one wide field", 
            actionButton(session$ns("add_user"), class = "ui basic green icon button", label = "",  icon = icon("add user"))
        )
    )
  )
}

#' @export
manage_user_ui = function(id){
  ns <- NS(id)
  tagList(
    uiOutput(ns("users_list")),
    uiOutput(ns("admin_modals")),
    uiOutput(ns("user_table_remove"))
  )
}

#' @export
manage_user_server = function(input, output, session){
  
  log = reactiveValues(state = "", event_target = NULL, event_action = NULL)
  
  users <- reactive({

    input$add_user
    log$event_action

    con <- dbConnect(SQLite(), "data/user.db") # Creates database file test.db
    out <- con %>%
      tbl("users")  %>%
      as_tibble

    dbDisconnect(con)
    return(out)
  })
  
  output$users_list <- renderUI({
    
    #req(users())
    
    log$event_action
    input$add_user
    
    return(
      tagList(
        div(class = "ui form",
            add_user_table_entry(session),
            users() %>% 
              split(1:nrow(.)) %>% 
              purrr::map(~{
                user_table_entry(.x, session)
              })
        )
      )
    )
  })
  
  observe({
    users() %>%
      split(1:nrow(.)) %>%
      purrr::map(~{
        observeEvent(input[[glue::glue("{.x$user}_remove")]], {
          log$event_action <- "remove_user"
          log$event_target <- .x$user
        })
      })
  })
  
  observe({
    users() %>%
      split(1:nrow(.)) %>%
      purrr::map(~{
        observeEvent(input[[glue::glue("{.x$user}_unhash")]], {
          log$event_action <- "unhash_password"
          log$event_target <- .x$user
        })
      })
  })
  
  ### Remove user
  observeEvent(log$event_action, {
    if(log$event_action == "remove_user"){
      con <- dbConnect(SQLite(), "data/user.db") # Creates database file test.db
      con  %>%
        sql_delete_row("users", "user", log$event_target)
      
      dbDisconnect(con)
    }
    
    log$event_action <- ""
    log$event_target <- ""
  })
  
  ### Add user
  observeEvent(input$add_user, {
    
    log$event_action <- "add_user"
    log$event_target <- input$new_user
    
    user_profile <- tibble(
      user = input$new_user,
      password = input$new_pw,
      signed_in = Sys.time(),
      role = input$new_role
    )
    
    user_event <- tibble(
      user = input$new_user,
      time = Sys.time(),
      event = "signed_in"
    )
    
    con <- dbConnect(SQLite(), "data/user.db") # Creates database file test.db
    dbWriteTable(con, "users", user_profile, append = T)
    dbDisconnect(con)
    
    log$event_action <- ""
    log$event_target <- ""
  })
}