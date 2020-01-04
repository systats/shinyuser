#' theme_ui
#' https://stackoverflow.com/questions/19844545/replacing-css-file-on-the-fly-and-apply-the-new-style-to-the-page
#' @export
theme_ui <- function(id){
  ns <- NS(id)
  tagList(
    span(textOutput(ns("type"), inline = T), style="margin-right:.5cm"),
    toggle_slider(ns("daynight"), label = "", checked = F)
    #dropdown(ns("theme"), choices = c("default", shiny.semantic::SUPPORTED_THEMES), value = "default")
  )
}

#' list_themes
#' @export
list_themes <-  shiny.semantic::SUPPORTED_THEMES %>%
  set_names(shiny.semantic::SUPPORTED_THEMES) %>%
  imap(~ glue::glue("https://d335w9rbwpvuxm.cloudfront.net/semantic.{.x}.min.css")) %>%
  c(list("default" = "https://d335w9rbwpvuxm.cloudfront.net/semantic.min.css"))

#' theme_server
#' @export
theme_server <- function(input, output, session){
  
  # observeEvent(input$daynight, {
  #   if(input$daynight){
  #     runjs(glue::glue("setStyleSheet('{list_themes[['cyborg']]}')"))
  #   } else {
  #     runjs(glue::glue("setStyleSheet('{list_themes[['default']]}')"))
  #   }
  # })
  
  observeEvent(input$daynight, {
    if(input$daynight){
      runjs(glue::glue("changeCSS('{list_themes[['cyborg']]}', 0)"))
    } else {
      runjs(glue::glue("changeCSS('{list_themes[['default']]}', 0)"))
    }
  })
  
  
  output$type <- renderText({
    #req(input$daynight)
    if(is.null(input$daynight)) return("Hell")
    if(input$daynight){
      "Dunkel"
    } else {
      "Hell"
    }
  })
  
  outputOptions(output, "type", suspendWhenHidden = F)
}
