#' check_name
#' @export
check_name = function(name){
  if(is.null(name)) return(T)
  if(is.na(name)) return(T)
  if(name == "") return(T)
  if(stringr::str_length(name) < 4) return(T)
  return(F)
}

#' user
#' @export
user <- R6::R6Class("user",
  private = list(
    users = NULL
  ),
  active = list(
    
    
    warn_user_exists = function(){
      self$session$message <- "Fail: username already exists in the DB"
    },
    
    warn_cred_wrong = function(){
      self$session$message <- "Fail: You might have misspelled your username or password!"
    },
    
    warn_cred_unequal = function(){
      self$session$message <- "Fail: password1 and .sceret2 do not match"
    },
    
    warn_user_wrong = function(){
      self$session$message <- "Fail: Your username is either to short or null"
    },
    
    warn_password_length = function(){
      self$session$message <- "Fail: Your password is either to short or null"
    },
    
    ok_login = function(){
      self$session$message <- as.character(glue::glue("<message> Hi {self$session$username }, welcome back!"))
    },
    
    ok_signin = function(){
      self$session$message <- as.character(glue::glue("<message> Hi {self$session$username }, welcome on our platform!"))
    }
    
  ),
  public = list(
    
    path = NULL,
    user = NULL,
    session = list(username = "", role = "", message = "", status = 0), #    users = NULL, 
    
    initialize = function(users){
      private$users <- users
    },
    
    reset = function(){
      self$session <- list(status = 0, message = "Success: Logged out", username = "", role = "")
    },
    
    login = function(user, pw){
      
      ### handle corrupted username
      if(check_name(user)) return(self$warn_user_wrong)
      ### handle corrupted passwords
      if(check_name(pw)) return(self$warn_cred_wrong)
      
      test <- private$users %>%
        dplyr::filter(username == user) %>% 
        dplyr::filter(password == pw) %>%
        glimpse
      
      if(nrow(test) == 1) {
        #self$session <- list(username = "", role = "", message = "", status = 0)
        self$session <- test %>% dplyr::mutate(status = 1)
        self$ok_login
      } else {
        self$session <- tibble(user, pw) %>% dplyr::mutate(status = 0)
        self$warn_cred_wrong
      }
    },
    
    logout = function(){
      self$session$status <- 0
      self$session$username <- ""
      self$session$message <- "Info: successfully logged out"
    }
  )                        
)