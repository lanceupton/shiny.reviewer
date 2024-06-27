
message("* Use DEV_run() to build and test the application.")
DEV_run <- function() {
  attachment::att_amend_desc()
  renv::snapshot(prompt = FALSE)
  withr::with_envvar(c(RENV_PROFILE = NULL), renv::snapshot(prompt = FALSE))
  shinyMobile::preview_mobile(appPath = ".", device = 'iphone8+')
}

message("* Use DEV_restart() to restart the R session.")
DEV_restart <- function() {
  rstudioapi::restartSession(clean = TRUE)
}

# Key methods from https://github.com/RamiKrispin/shinylive-r
message("* Use DEV_render() to render the demo_app gh site files.")
DEV_render <- function() {
  shinylive::export(appdir = ".", destdir = "docs")
}
message("* Use DEV_preview() to preview the demo_app gh site.")
DEV_preview <- function() {
  httpuv::runStaticServer("docs/", port = 8008)
}
