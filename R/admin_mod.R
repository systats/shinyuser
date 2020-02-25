#' admin_ui
#' @export
admin_ui <- function(id){
  ns <- NS(id)
  tagList(
    div(class="ui modal", id = "admin-modal",
      span(class = "ui header",
        "Admin Panel"
      ),
      #actionButton(session$ns("back"), class = "ui right floated basic inverted circular icon button", label = "", icon = icon("remove")),
      div(class = "scrolling content", #align = "left", style = "width: 80%; min-height: 100vh;",
        div(class = "ui stackable grid",
          div(class = "row",
            div(class = "two wide column",
                shiny::actionButton(inputId = ns("NEW-user"), label = "", class = "ui green compact icon button", icon = icon("user plus"))
            ),
            div(class="four wide column",
                dropdown(name = "sortby", choices = c("role"), value = "role")
            ),
            div(class = "six wide column",
                uiOutput(ns("search_user_selection"))
            )
          ),
          div(class = "row",
            div(class = "sixteen wide column",
                shiny::uiOutput(ns("dev"))
            )
          )
        )
      )
    )
  )
}

#' admin_server
#' @export
admin_server <- function(input, output, session, user_data){

  ### show admin panel 
  # observeEvent(input$show, {
  #   shinyjs::runjs("$('#admin-modal').modal('show');")
  # })
  
  # ### create new user
  # observeEvent(input$`NEW-user`, {
  #   #browser()
  #   new <- user$new("data/users")
  #   new$username <- "NEW"
  #   new$password <- ""
  #   new$role <- "client"
  #   new$update()
  #   new$reset()
  # })
  
  ### load users + updating removed once
  # users <- reactive({
  #   req(user_data())
  #   if(user_data()$status == 0) return(NULL)
  #   
  #   out <- dir("data/users", full.names = T) %>%
  #     map_dfr(jsonlite::fromJSON) %>%
  #     #mutate(role = "admin") %>%
  #     mutate(session_id = session$ns(username)) %>%
  #     arrange(desc(ifelse(username == "NEW", 1, 0)))
  #   
  #   ### trigger reload
  #   input$`NEW-user`
  #   #input$`A-NEW-USER-remove`
  #   out$username %>% purrr::map(~{  input[[paste0(.x, "-remove")]] })
  # 
  #   out
  # })
  # 
  # output$dev <- renderUI({
  #   req(users())
  #   users() %>%
  #     split(1:nrow(.)) %>%
  #     map(entry_ui)
  # })
  # 
  # outputOptions(output, "dev", suspendWhenHidden = F)
  # 
  # observe({
  #   req(users())
  #   users() %>%
  #     split(1:nrow(.)) %>%
  #     purrr::walk(~{ callModule(entry_server, .x$username, .x) })
  # })
  # 
  # output$search_user_selection <- renderUI({
  #   shiny.semantic::search_selection_choices(
  #     name = session$ns("search_user"), 
  #     choices = users()$username,
  #     value = NULL, 
  #     multiple = T
  #   )
  # })
}


