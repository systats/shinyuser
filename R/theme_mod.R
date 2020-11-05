#' #' theme_ui
#' #' https://stackoverflow.com/questions/19844545/replacing-css-file-on-the-fly-and-apply-the-new-style-to-the-page
#' theme_ui <- function(id){
#'   ns <- NS(id)
#'   tagList(
#'     span(textOutput(ns("type"), inline = T), style="margin-right:.5cm"),
#'     toggle_slider(ns("daynight"), label = "", checked = F)
#'     #dropdown(ns("theme"), choices = c("default", shiny.semantic::SUPPORTED_THEMES), value = "default")
#'   )
#' }
#' 
#' #' list_themes
#' list_themes <-  shiny.semantic::SUPPORTED_THEMES %>%
#'   purrr::set_names(shiny.semantic::SUPPORTED_THEMES) %>%
#'   purrr::imap(~ glue::glue("https://d335w9rbwpvuxm.cloudfront.net/semantic.{.x}.min.css")) %>%
#'   c(list("default" = "https://d335w9rbwpvuxm.cloudfront.net/semantic.min.css"))
#' 
#' 
#' #' theme_server
#' 
#' theme_server <- function(input, output, session){
#'   
#'   # observeEvent(input$daynight, {
#'   #   if(input$daynight){
#'   #     runjs(glue::glue("setStyleSheet('{list_themes[['cyborg']]}')"))
#'   #   } else {
#'   #     runjs(glue::glue("setStyleSheet('{list_themes[['default']]}')"))
#'   #   }
#'   # })
#'   
#'   default <- "https://d335w9rbwpvuxm.cloudfront.net/semantic.min.css"
#'   dark <- "https://d335w9rbwpvuxm.cloudfront.net/semantic.cyborg.min.css"
#'   
#'   observeEvent(input$daynight, {
#'     req(input$daynight)
#'     if(input$daynight){
#'       shinyjs::runjs(glue::glue('$("link[src="<default>"]").attr("src","<dark>");', .open = "<", .close = ">"))
#'     } else {
#'       shinyjs::runjs(glue::glue('$("link[src="<dark>"]").attr("src","<default>");', .open = "<", .close = ">"))
#'     }
#'   })
#' 
#'   output$type <- renderText({
#'     #req(input$daynight)
#'     if(is.null(input$daynight)) return("Hell")
#'     if(input$daynight){
#'       "Dunkel"
#'     } else {
#'       "Hell"
#'     }
#'   })
#'   
#'   outputOptions(output, "type", suspendWhenHidden = F)
#' }
#' 
#' 
#' 
#' 
#' 
#' 
#' 
