
pkgload::load_all()
app_run(
  title = "shiny.reviewer Demo",
  content_meta = CONTENT_META_EXAMPLE,
  reviews = REVIEWS_EXAMPLE, 
  group_meta = GROUP_META_EXAMPLE,
  callback = function(df) {
    print(df)
  },
  public_proof = TRUE,
  launch.browser = TRUE
)
