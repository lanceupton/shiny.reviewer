
#' @importFrom tibble tibble
format_reviews <- function(df, latest = FALSE) {
  tibble(
    content_id = as.character(df$content_id),
    timestamp = as.POSIXct(df$timestamp),
    rating = as.integer(df$rating),
    difficulty = as.integer(df$difficulty),
    blacklist = as.logical(df$blacklist),
    notes = as.character(df$notes)
  )
}


#' @importFrom dplyr distinct
#' @importFrom tibble tibble
format_content_meta <- function(df) {
  tibble(
    group_id = as.character(df$group_id),
    id = as.character(df$id),
    title = as.character(df$title)
  ) |> distinct(id, .keep_all = TRUE)
}

#' @importFrom dplyr distinct
#' @importFrom tibble tibble
format_group_meta <- function(df) {
  tibble(
    id = as.character(df$id),
    title = as.character(df$title),
    img_src = as.character(df$img_src)
  ) |> distinct(id, .keep_all = TRUE)
}

#' @importFrom stringr str_extract_all
extract_emojis <- function(text) {
  # No PCRE support on shinyapps.io, so use stringr::str_extract_all
  # matches <- gregexpr("\\p{Emoji}", text, perl = TRUE)
  # unique(unlist(regmatches(text, matches)))
  unique(unlist(str_extract_all(text, "\\p{Emoji}")))
}

# https://github.com/jcheng5/rpharma-demo/blob/master/modules/bookmark_module.R
#' @importFrom lubridate day days hours minutes round_date seconds time_length
friendly_timestamp <- function(t) {
  if (is.null(t)) return()
  t <- round_date(t, "seconds")
  now <- round_date(Sys.time(), "seconds")
  abs_day_diff <- abs(day(now) - day(t))
  age <- now - t
  abs_age <- abs(age)
  future <- age != abs_age
  dir <- ifelse(future, "from now", "ago")
  format_rel <- function(singular, plural = paste0(singular, "s")) {
    x <- as.integer(round(time_length(abs_age, singular)))
    sprintf("%d %s %s", x, ifelse(x == 1, singular, plural), dir)
  }
  ifelse(abs_age == seconds(0), "Now",
         ifelse(abs_age < minutes(1), format_rel("second"),
                ifelse(abs_age < hours(1), format_rel("minute"),
                       ifelse(abs_age < hours(6), format_rel("hour"),
                              # Less than 24 hours, and during the same calendar day
                              ifelse(abs_age < days(1) & abs_day_diff == 0, strftime(t, "%I:%M:%S %p"),
                                     ifelse(abs_age < days(3), strftime(t, "%a %I:%M:%S %p"),
                                            strftime(t, "%Y/%m/%d %I:%M:%S %p")
                                     ))))))
}

"%||%" <- function(x, y) {
  if (isTruthy(x)) x else y
}
