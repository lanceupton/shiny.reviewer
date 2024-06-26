
pkgload::load_all()
reviewer <- ShinyReviewer$new(
  reviews = REVIEWS_EXAMPLE, 
  content_meta = CONTENT_META_EXAMPLE,
  group_meta = GROUP_META_EXAMPLE
)
reviewer$run_app(
  title = "Mario Kart Wii Track Logger",
  callback = function(df) {
    print(df)
  }
)
