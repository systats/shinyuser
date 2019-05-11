#' @export
dbConnect <- function(...){
  params <- list(...)
  print(params[[2]])
  DBI::dbConnect(...)
}

#' @export
check_user_db <- function(){
  ### User Auth/Admin
  if(!dir.exists("data")){
    dir.create("data")
  }
  con <- dbConnect(SQLite(), "data/user.db")
  
  if(length(dbListTables(con)) == 0){
    init <- tibble(user = "root", password = "2019", signed_in = NA, role = "admin") 
    dbWriteTable(con, "users", init)
  }
  
  message("User <root> with password <2019> was created")
  dbDisconnect(con)
}


