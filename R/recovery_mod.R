recovery_ui <- function(id){
  ns <- NS(id)
  tagList(
    br(),
    p("What is your Email Adress?"),
    div(class = "ui grid",
        div(class = "ten wide column",
            div(class = "ui left icon input",
                HTML('<i class="ui mail icon"></i>'),
                shiny::tags$input(id = ns("email"), type = "text", value="" , placeholder="email")
            )  
            
        ),
        div(class = "one wide column",
            action_button(ns("send"), label = "send")
        )
    ),
    br(),
    uiOutput(ns("code")),
    br(),
    uiOutput(ns("passwords"))
  )
}

recovery_server <- function(input, output, session){
  
  
  email_code <- reactive({
    paste0(
      sample(0:9, size = 1),
      sample(0:9, size = 1),
      sample(0:9, size = 1),
      sample(0:9, size = 1)
    )
  })
  
  
  email <- eventReactive(input$send, {
    if(str_detect(input$email, "^[[:alnum:].-_]+@[[:alnum:].-]+$")){
      input$email
    } else {
      NULL
    }
  })
  

  output$code <- renderUI({
    if(is.null(email())){
      tagList("")
    } else {
      tagList(
        p("We sent you an 4 number code to", br(), strong(email()), br(),
          "Please check now your mail"),
        div(class = "ui grid",
            div(class = "ten wide column",
                div(class = "ui left icon input",
                    HTML('<i class="ui mail icon"></i>'),
                    shiny::tags$input(id = session$ns("lock"), type = "text", value="" , placeholder="secure code")
                ) 
                
            ),
            div(class = "one wide column",
                action_button(session$ns("verify"), label = "verify")
            )
        )
      )
    }
  })
  
  
  observe({
    print(input$send)
    print(input$email)
    print(str_detect(input$email, "^[[:alnum:].-_]+@[[:alnum:].-]+$"))
    print(email())
    print(email_code())
  })
  
  verified <- eventReactive(input$verify, {
    if(email_code() == input$lock){
      "verified"
    } else {
      "not veriefied"
    }
  })
  
  observe({
    print(verified())
  })
  
  
  output$passwords <- renderUI({
    
    if(verified() != "verified"){
      tagList("")
    } else {
      tagList(
        p("Please provide twice the same new password"),
        div(class = "ui grid",
            div(class = "ten wide column",
                div(class = "ui left icon input",
                    HTML('<i class="ui key icon"></i>'),
                    shiny::tags$input(id = session$ns("pw1"), type = "password", value = "" , placeholder = "Secret")
                ),
                br(),
                br(),
                div(class = "ui left icon input",
                    HTML('<i class="ui key icon"></i>'),
                    shiny::tags$input(id = session$ns("pw2"), type = "password", value = "" , placeholder = "Secret")
                )
                
            ),
            div(class = "one wide column",
                br(),
                br(),
                br(),
                action_button(session$ns("change"), label = "change")
            )
        )
      )
    }
    
  })
  
  outputOptions(output, "code", suspendWhenHidden = FALSE)
  outputOptions(output, "passwords", suspendWhenHidden = FALSE)
}