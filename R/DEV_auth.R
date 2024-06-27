
#' Configure Google Sheets Authentication
#'
#' * Use `DEV_auth_set()` to create an encrypted gs4 token.
#' * Use `DEV_auth_get()` to read the token.
#'
#' @name DEV_auth
NULL

#' @rdname DEV_auth
#' @export
DEV_auth_set <- function(email, file = ".secrets/gs4-token.rds") {
  if (!requireNamespace("googlesheets4")) {
    stop("Please install `googlesheets4` to use this method.")
  }
  message("Creating a gs4 token for <", email, ">")
  key <- secret_make_key()
  gs4_auth(email = email, cache = FALSE)
  message("Saving the token to ", file)
  dir.create(dirname(file), showWarnings = FALSE, recursive = TRUE)
  secret_write_rds(gs4_token(), file, key)
  message("Configuring SHINYREVIEWER_TOKEN_FILE and SHINYREVIEWER_OAUTH_KEY")
  Sys.setenv(
    SHINYREVIEWER_TOKEN_FILE = file,
    SHINYREVIEWER_OAUTH_KEY = key
  )
  efile <- ".Renviron"
  message("Adding SHINYREVIEWER_TOKEN_FILE and SHINYREVIEWER_OAUTH_KEY to ", efile)
  elines <- if (file.exists(efile)) {
    readLines(efile)
  }
  xline <- grep("^SHINYREVIEWER_TOKEN_FILE=", elines)
  xnew <- sprintf("SHINYREVIEWER_TOKEN_FILE='%s'", file)
  if (length(xline) == 0) {
    elines <- c(elines, xnew)
  } else {
    elines[xline] <- xnew
  }
  xline <- grep("^SHINYREVIEWER_OAUTH_KEY=", elines)
  xnew <- sprintf("SHINYREVIEWER_OAUTH_KEY='%s'", key)
  if (length(xline) == 0) {
    elines <- c(elines, xnew)
  } else {
    elines[xline] <- xnew
  }
  writeLines(elines, efile)
}

#' @rdname DEV_auth
#' @export
DEV_auth_get <- function() {
  if (!requireNamespace("googlesheets4")) {
    stop("Please install `googlesheets4` to use this method.")
  }
  TOKEN_FILE <- Sys.getenv("SHINYREVIEWER_TOKEN_FILE")
  gs4_auth(token = secret_read_rds(TOKEN_FILE, "SHINYREVIEWER_OAUTH_KEY"))
}
