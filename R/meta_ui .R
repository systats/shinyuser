#' save_json
#' @export
meta_ui <- function(head = NULL, signin = T, recover = F){
  
  semanticPage <- function (..., title = "", theme = NULL){
    content <- shiny::tags$div(class = "wrapper", ...)
    shiny::tagList(shiny.semantic:::get_range_component_dependencies(), shiny::tags$head(if (!is.null(getOption("shiny.custom.semantic",
                                                                                                                NULL))) {
      get_dependencies()
    }
    else {
      shiny::tagList(shiny::tags$link(id="login-styles", rel="stylesheet", type="text/css", href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.min.css"), tags$script(src = shiny.semantic:::get_default_semantic_js()))
    }, shiny::tags$title(title), shiny::tags$meta(name = "viewport", content = "width=device-width, initial-scale=1.0"),
    shiny::tags$script(src = "shiny.semantic/shiny-semantic-modal.js"), id="login-js"),
    shiny::tags$body(style = "min-height: 611px;", content))
  }
  
  semanticPage(
      #shinytoastr::useToastr(),
      shinyjs::useShinyjs(),
      suppressDependencies("bootstrap"),
      #suppressDependencies("semantic-ui"),
      #suppressDependencies("plotlyjs"),
      tags$head(
        HTML(
          '<script>
            function setStyleSheet(url){
              var stylesheet = document.getElementById("stylesheet");
              stylesheet.setAttribute("href", url);
            }
          </script>'
        ),
        
        #shiny::tags$link(id="checkin_styles", rel="stylesheet", type="text/css", href="https://d335w9rbwpvuxm.cloudfront.net/semantic.min.css"),
        
        tags$script('function changeCSS(cssFile, cssLinkIndex) {

            var oldlink = document.getElementsByTagName("link").item(cssLinkIndex);
        
            var newlink = document.createElement("link");
            newlink.setAttribute("rel", "stylesheet");
            newlink.setAttribute("type", "text/css");
            newlink.setAttribute("href", cssFile);
        
            document.getElementsByTagName("head").item(0).replaceChild(newlink, oldlink);
        }'),
        shiny::tags$script(
          "$(document).ready(function() {
                $('.ui.accordion')
                  .accordion();
                })"
        ),
        # https://stackoverflow.com/questions/32335951/using-enter-key-with-action-button-in-r-shiny
        shiny::tags$script('
              $(document).keyup(function(event) {
                  if (event.key == "Enter") {
                      $("#user-login").click();
                  }
              });'
        )
        #tags$script("function refresh(){ history.go(0); }")
        #tags$script("shinyjs.refresh = function() { history.go(0); }")
        # tags$script(
        #   'function setStyleSheet(url){
        #     var stylesheet = document.getElementById("stylesheet");
        #     stylesheet.setAttribute("href", url);
        #   }'
        # ),
        #tags$link(id="stylesheet", rel="stylesheet", type="text/css", href="https://d335w9rbwpvuxm.cloudfront.net/semantic.min.css"),
        #tags$script(src = "https://d335w9rbwpvuxm.cloudfront.net/semantic.min.js"),
        #tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/semantic-ui/2.2.6/semantic.min.css"),
        #tags$script(src = "https://cdn.plot.ly/plotly-1.20.2.min.js"),
        #tags$link(rel = "stylesheet", type = "text/css", href = "layout.css"),
        #tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/numeral.js/2.0.4/numeral.min.js"),
        ### shiny.stats
        #shiny.stats::browser_info_js
      ),
      uiOutput("authorized")
    )
}




