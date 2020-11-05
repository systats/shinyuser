#' admin_ui
#' @export
admin_ui <- function(id){
  ns <- NS(id)
  tagList(
      # div(class="ui modal", id = "user-details",
      # 
      # ),
      #div(class="ui modal", id = "admin-modal",
      span(class = "ui header",
        "Admin Panel"
      ),
      #actionButton(session$ns("back"), class = "ui right floated basic inverted circular icon button", label = "", icon = icon("remove")),
      div(class = "scrolling content", #align = "left", style = "width: 80%; min-height: 100vh;",
        div(class = "ui stackable grid",
          div(class = "row",
            div(class = "two wide column",
              shiny::actionButton(inputId = ns("new_user"), label = "", class = "ui green compact icon button", icon = icon("user plus"))
            ),
            div(class="four wide column",
              dropdown_input(input_id = ns("sortby"), choices = c("admin", "client"), value = "role")
            ),
            div(class = "six wide column",
                uiOutput(ns("search_user_selection"))
            )
          ),
          div(class = "row",
            div(class = "sixteen wide column",
              DT::DTOutput(ns("list"))
            )
          )
        ),
        div(class = "ui divider"),
        div(class = "ui form",
            div(class = "fields",
                div(class = "field",
                    textInput(ns("username"), label = "", value = "")
                ),
                div(class = "field",
                    textInput(ns("pw"), label = "", value = "") 
                )
            )    
        )
      #)
    )
  )
}

#' admin_server
#' @export
admin_server <- function(input, output, session, users){

  output$search_user_selection <- renderUI({
    shiny.semantic::search_selection_choices(
      input_id = session$ns("search_user"),
      choices = users()$username,
      value = NULL,
      multiple = T
    )
  })
  
  output$list <- DT::renderDT({
    req(users())
    DT::datatable(users(), selection = list(mode = "single"))
  })
  
  selected <- reactive({
    req(input$list_rows_selected)
    
    target <- input$list_rows_all[which(input$list_rows_all %in% input$list_rows_selected)]
    users() %>%
      dplyr::slice(target)
  })
  
  observeEvent({input$list_rows_selected},{
    shinyjs::runjs("$('#user-details').modal('show');")
  }, ignoreInit = T)
  
  observe({
    glimpse(selected())
  })

  outputOptions(output, "list", suspendWhenHidden = F)
}


