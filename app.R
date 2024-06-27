
pkgload::load_all()
app_run(
  title = "shiny.reviewer Demo Application",
  content_meta = CONTENT_META_EXAMPLE,
  reviews = REVIEWS_EXAMPLE, 
  group_meta = GROUP_META_EXAMPLE,
  callback = function(df) {
    print(df)
  },
  launch.browser = TRUE
)
