#' toggle_input
#' @export
toggle_input <- function(id, label = NULL, fitted = F, checked = F, class = NULL){
  fit <- NULL
  check <- NULL
  if (fitted) fit <- "fitted"
  if (checked) check <- "checked"
  variation <- paste("ui", fit, "toggle checkbox", sep = " ")
  
  if (!is.null(class)) 
    variation <- class
  htmltools::tagList(htmltools::div(class = variation, htmltools::tags$input(id = id, type = "checkbox", checked = check), htmltools::tags$label(label, style = "color:white;")))
}

#' toggle_slider
#' @export
toggle_slider <- function(id, label = NULL, fitted = F, checked = F, class = NULL){
  fit <- NULL
  check <- NULL
  if (fitted) fit <- "fitted"
  if (checked) check <- "checked"
  variation <- paste("ui", fit, "slider checkbox", sep = " ")
  
  if (!is.null(class)) 
    variation <- class
  htmltools::tagList(htmltools::div(class = variation, htmltools::tags$input(id = id, type = "checkbox", checked = check), htmltools::tags$label(label, style = "color:white;")))
}
