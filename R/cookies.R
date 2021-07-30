# https://gist.github.com/calligross/e779281b500eb93ee9e42e4d72448189
#' js_cookies
#' @export 
js_cookies <- '
  shinyjs.getcookie = function(params) {
    var cookie = Cookies.get("id");
    if (typeof cookie !== "undefined") {
      Shiny.onInputChange("user-jscookie", cookie);
    } else {
      var cookie = "";
      Shiny.onInputChange("user-jscookie", cookie);
    }
  }
  shinyjs.setcookie = function(params) {
    Cookies.set("id", escape(params), { expires: 0.5 });  
    Shiny.onInputChange("user-jscookie", params);
  }
  shinyjs.rmcookie = function(params) {
    Cookies.remove("id");
    Shiny.onInputChange("user-jscookie", "");
  }
'

#' create_cookie
#' @export
create_cookie <- function(user){
  timestamp <- lubridate::ceiling_date(lubridate::now(), "1 hour")
  openssl::sha1(paste(Sys.getenv("CRYPT_KEY"), user, timestamp, sep = "_"))
}