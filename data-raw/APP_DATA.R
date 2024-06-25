
# CONTENT_META
# group_id: A string giving the group id (matched with GROUP_META$id)
# id: A string giving the track id (matched with DATA_SUMMARY$content_id)
# title: A string giving a title to display in the content button
CONTENT_META_EXAMPLE <- read.csv("data-raw/CONTENT_META_EXAMPLE.csv")

# GROUP_META_EXAMPLE
# id: A string giving the group id (matched with CONTENT_META$group_id)
# title: A string giving a title to display in the group card
# img_src: A string giving an img source for the group card image
GROUP_META_EXAMPLE <- read.csv("data-raw/GROUP_META_EXAMPLE.csv")

# REVIEWS_EXAMPLE
# Random reviews data
REVIEWS_EXAMPLE <- data.frame(
  content_id = sample(CONTENT_META_EXAMPLE$id, 50, replace = TRUE),
  timestamp = as.POSIXct(replicate(50, {
    time <- as.numeric(Sys.time())
    runif(1, min = time - 1000000, max = time)
  }), origin = "1970-01-01"),
  rating = sample(5, 50, replace = TRUE),
  difficulty = sample(3, 50, replace = TRUE),
  blacklist = sample(c(FALSE,TRUE), 50, replace = TRUE, prob = c(0.8, 0.2)),
  notes = as.character(replicate(50, {
    n <- sample(0:3, 1, prob = c(.5, .2, .2, .1))
    paste0(sample(strsplit("🐌🐀🐓🐤🐢", "")[[1]], n, replace = TRUE), collapse = "")
  }))
)

usethis::use_data(CONTENT_META_EXAMPLE, GROUP_META_EXAMPLE, REVIEWS_EXAMPLE, overwrite = TRUE)
