#' save_json
#' @export
meta_ui <- function(){
  shinyUI(
    shiny.semantic::semanticPage(
      #shinytoastr::useToastr(),
      shinyjs::useShinyjs(),
      shinyjs::extendShinyjs(text =  "shinyjs.refresh = function() { history.go(0); }"),
      suppressDependencies("bootstrap"),
      #suppressDependencies("plotlyjs"),
      #suppressDependencies("semantic-ui"),
      tags$head(
        #tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/semantic-ui/2.2.6/semantic.min.css"),
        #tags$script(src = "https://cdn.jsdelivr.net/semantic-ui/2.2.6/semantic.min.js"),
        #tags$script(src = "https://cdn.plot.ly/plotly-1.20.2.min.js"),
        #tags$link(rel = "stylesheet", type = "text/css", href = "layout.css"),
        #tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/numeral.js/2.0.4/numeral.min.js"),
        ### shiny.stats
        #shiny.stats::browser_info_js
      ),
      
      login_ui("user"), 
      uiOutput("authorized")
    )
  )
}