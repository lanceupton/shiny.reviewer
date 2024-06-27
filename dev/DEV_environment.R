
message("* Use DEV_run() to build and test the application.")
DEV_run <- function() {
  attachment::att_amend_desc()
  renv::snapshot(prompt = FALSE)
  withr::with_envvar(c(RENV_PROFILE = "default"), renv::snapshot(prompt = FALSE))
  shinyMobile::preview_mobile(appPath = ".", device = 'iphone8+')
}

message("* Use DEV_restart() to restart the R session.")
DEV_restart <- function() {
  rstudioapi::restartSession(clean = TRUE)
}
