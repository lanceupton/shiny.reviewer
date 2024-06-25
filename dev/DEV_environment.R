
message("* Use DEV_run() to build and test the application.")
DEV_run <- function() {
  attachment::att_amend_desc()
  renv::snapshot(prompt = FALSE)
  pkgload::load_all()
  reviewer <- ShinyReviewer$new(
    reviews = REVIEWS_EXAMPLE, 
    content_meta = CONTENT_META_EXAMPLE,
    group_meta = GROUP_META_EXAMPLE
  )
  reviewer$run_app(
    title = "DEVELOPMENT",
    callback = function(df) {
      print(df)
    },
    launch.browser = TRUE
  )
}

message("* Use DEV_restart() to restart the R session.")
DEV_restart <- function() {
  rstudioapi::restartSession(clean = TRUE)
}
