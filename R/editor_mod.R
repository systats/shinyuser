#' editor_ui
#' @export
editor_ui <- function(id){
  ns <- NS(id)
  tagList(
    box(width = 16, title = "Personal",ribbon = F, title_side = "top right",
      div(class="ui form",
        div(class="inline fields", 
            div(class="two wide field", 
              label("User"),
            ),
            div(class="seven wide field", `data-tooltip` = "Provide a username", `data-position`="bottom center",
              shiny::textInput(ns("user"), "", placeholder = "Username",  value = "")
            ),
            div(class="seven wide field", `data-tooltip` = "Provide a password", `data-position`="bottom center",
              shiny::passwordInput(ns("pw1"), "", placeholder = "Password",  value = "")
            )
        )
      ),
      div(class="ui form",
        div(class="inline fields", 
            div(class="two wide field", 
                label("Names"),
            ),
            div(class="seven wide field", 
                shiny::textInput(ns("first"), "", placeholder = "First Name",  value = "")
            ),
            div(class="seven wide field", 
                shiny::textInput(ns("last"), "", placeholder = "Last Name",  value = "")
            )
        )
      )
    ),
    br(),
    box(width = 16, title = "Mails", ribbon = F, title_side = "top right",
      div(class="ui form", 
        div(class="fields", 
            div(class="two wide field", 
                label("Mail I")
            ),
            div(class="seven wide field", 
                shiny::textInput(ns("email1"), "", placeholder = "Email",  value = "")
            ),
            div(class="seven wide field", 
                shiny::passwordInput(ns("mail_secret1"), "", placeholder = "Secret", value = "")
            )
        )
      )
    ),
    br()
  )
}


#' editor_server
#' @export
editor_server <- function(input, output, session, user){

  
}