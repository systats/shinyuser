#' save_json
#' @export
meta_ui <- function(){
  tagList(
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
          </script>
          <link id="stylesheet" rel="stylesheet" type="text/css" href="https://d335w9rbwpvuxm.cloudfront.net/semantic.min.css"/>'
        ),
        tags$script('function changeCSS(cssFile, cssLinkIndex) {

            var oldlink = document.getElementsByTagName("link").item(cssLinkIndex);
        
            var newlink = document.createElement("link");
            newlink.setAttribute("rel", "stylesheet");
            newlink.setAttribute("type", "text/css");
            newlink.setAttribute("href", cssFile);
        
            document.getElementsByTagName("head").item(0).replaceChild(newlink, oldlink);
        }'),
        tags$script("shinyjs.refresh = function() { history.go(0); }")
        # tags$script(
        #   'function setStyleSheet(url){
        #     var stylesheet = document.getElementById("stylesheet");
        #     stylesheet.setAttribute("href", url);
        #   }'
        # ),
        # tags$link(id="stylesheet", rel="stylesheet", type="text/css", href="https://d335w9rbwpvuxm.cloudfront.net/semantic.min.css"),
        #tags$script(src = "https://d335w9rbwpvuxm.cloudfront.net/semantic.min.js"),
        #tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/semantic-ui/2.2.6/semantic.min.css"),
        #tags$script(src = "https://cdn.plot.ly/plotly-1.20.2.min.js"),
        #tags$link(rel = "stylesheet", type = "text/css", href = "layout.css"),
        #tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/numeral.js/2.0.4/numeral.min.js"),
        ### shiny.stats
        #shiny.stats::browser_info_js
      ),
      
      login_ui("user"), 
      uiOutput("authorized")
    )
}