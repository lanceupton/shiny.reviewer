
message("* Use DEV_run() to build and test the application.")
DEV_run <- function() {
  attachment::att_amend_desc()
  renv::snapshot(prompt = FALSE)
  withr::with_envvar(c(RENV_PROFILE = "default"), renv::snapshot(prompt = FALSE))
  source("app.R")
  # shinyMobile::preview_mobile(appPath = ".", device = 'iphone8+')
}

message("* Use DEV_restart() to restart the R session.")
DEV_restart <- function() {
  rstudioapi::restartSession(clean = TRUE)
}

message("* Use DEV_deploy() to deploy the demo app.")
DEV_deploy <- function() {
  rsconnect::deployApp(
    appName = "shiny-reviewer-demo",
    appFiles = c("app.R", "data", "DESCRIPTION", "inst", "NAMESPACE", "R", "renv.lock")
  )
}
