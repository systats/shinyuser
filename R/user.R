#' save_json
#' @export
save_json <- function(file, name, path){
  file %>% 
    jsonlite::toJSON(force = T) %>% 
    jsonlite::fromJSON() %>% 
    jsonlite::toJSON(pretty = TRUE) %>% 
    writeLines(., glue::glue("{path}/{name}.json"))
}

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
  active = list(
    
    username = function(user){
      if(missing(user)) return(self$params$username)
      self$params$username <- user
    },
    
    password = function(pw){
      if(missing(pw)) return(self$params$password)
      self$params$password <- pw
    },
    
    role = function(role){
      if(missing(role)) return(self$params$role)
      self$params$role <- role
    },
    
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
      self$session$status <- 1
      self$session$message <- as.character(glue::glue("<message> Hi {self$params$username }, welcome back!"))
    },
    
    ok_signin = function(){
      self$session$status <- 1
      self$session$message <- as.character(glue::glue("<message> Hi {self$username }, welcome on our platform!"))
    }
    
  ),
  public = list(
    
    path = NULL,
    params = NULL,
    session = list(status = 0, message = "", username = "", role = ""), 
    
    # list(
    #   username = "",
    #   password = "",
    #   logs = list(
    #     error = 0,
    #     last = 0,
    #     total = 0
    #   )
    #   #roles = NULL
    # ),
    
    initialize = function(path){
      self$path <- path
    },
    
    reset = function(){
      self$params <- NULL
      self$session <- list(status = 0, message = "Success: Logged out", username = "")
    },
    
    load = function(user){
      
      self$session$username <- user
      path <- as.character(glue::glue("{self$path}/{user}.json"))
      if(!file.exists(path)) return(NULL)
      #print(path)
      self$params <- jsonlite::fromJSON(path)
    }, 
    
    update = function(){
      
      ### does the username already exist?
      target <- glue::glue("{self$path}/{self$params$username}.json")
      if(!file.exists(target)) return(self$save())
      
      self$params <- jsonlite::fromJSON(glue::glue("{self$path}/{self$params$username}.json"))
      
      params <- as_tibble(self$params)
      if(is.null(params)) return(NULL)
      
      test <- jsonlite::fromJSON(target)
      if(length(params) < length(test)) return(NULL)
      
      self$save()
    },
    
    save = function(){
      save_json(as_tibble(self$params), self$params$username, self$path)
      self$params <- jsonlite::fromJSON(glue::glue("{self$path}/{self$params$username}.json"))
    },
    
    remove = function(user = NULL, prompt = T){
      
      if(is.null(user)) user <- self$username 
      
      path <- glue::glue("{self$path}/{user}.json")
      
      if(prompt){
        if(askYesNo("Do you really want to remove the user?")) file.remove(path)
      } else {
        file.remove(path)
      }
    },
    
    add = function(...){
      list(...) %>% iwalk(~ { self$params[[.y]] <- .x })
    },
    
    login = function(user, pw){
      
      ### handle corrupted username
      if(check_name(user)) return(self$warn_user_wrong)
      ### handle corrupted passwords
      if(check_name(pw)) return(self$warn_cred_wrong)
      
      test <- dir(self$path, full.names = T) %>% 
        purrr::map_dfr(jsonlite::fromJSON) %>%
        dplyr::filter(username == user) %>% 
        dplyr::filter(password == pw)
      
      if(nrow(test) == 1) {
        self$username <- test$user 
        self$session$username <- test$user 
        self$session$role <- test$role 
        self$ok_login
        self$update()
      } else {
        self$warn_cred_wrong
      }
    },
    
    logout = function(){
      self$session$status <- 0
      self$session$username <- ""
      self$session$message <- "Info: successfully logged out"
    },
    
    recover = function(email){
      self$session$message <- glue::glue("Success:: Email has been sent to {email}")
    },
    
    register = function(user, pw1, pw2){
      
      ### handle corrupted username
      if(check_name(user)) return(self$warn_user_wrong)
      ### handle corrupted passwords
      if(check_name(pw1)) return(self$warn_cred_wrong)
      if(check_name(pw2)) return(self$warn_cred_wrong)
      
      sample <- dir(self$path, full.names = T) %>% 
        purrr::map_dfr(jsonlite::fromJSON) %>%
        dplyr::filter(username == user)
      
      if(nrow(sample) > 0) return(self$warn_user_exists)
      
      if(pw1 == pw2) {
        
        self$username <- user 
        self$password <- pw1
        self$role <- "client" 
        
        self$session$username <- user 
        self$session$role <- "client" 
        
        self$ok_signin
        self$update()
        
      } else {
        self$warn_cred_unequal 
      }
    }
  )                        
)