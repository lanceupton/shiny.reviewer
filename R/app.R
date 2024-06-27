
app_sys <- function(...) {
  system.file(..., package = "shiny.reviewer")
}

#' Run the Shiny Application.
#' 
#' @param title An application title.
#' @param content_meta A data frame with `group_id` (optional), `id`, and
#'   `title`. If `group_id` is provided, content is grouped within cards.
#' @param reviews (Optional) A data frame with `content_id`, `timestamp`,
#'   `rating`, `difficulty`, `blacklist`, and `notes`.
#' @param group_meta (Optional) A data frame with `id`, `title`, and `img_src`,
#'   used to create group cards.
#' @param callback (Optional) A `function(df)` to do something with the
#'   reviews submitted within a session when it ends.
#' @param ... Options passed to `shiny::shinyApp()`
#' 
#' @import shiny
#' @import shinyMobile
#' @importFrom dplyr bind_rows filter group_walk rowwise slice_max
#' @export
app_run <- function(title, content_meta, reviews = NULL, group_meta = NULL, callback = NULL, ...) {
  # Format application data
  reviews <- format_reviews(reviews)
  content_meta <- format_content_meta(content_meta)
  group_meta <- format_group_meta(group_meta)
  # Initialize a global reactive element for each content_id describing
  # its input state - this will be read/modified directly by user sessions
  LATEST_REVIEWS <- reactiveValues()
  rowwise(content_meta) |>
    group_walk(function(df, key) {
      xid <- df$id
      # Select most recent review
      xreview <- filter(reviews, content_id == xid) |>
        slice_max(timestamp)
      LATEST_REVIEWS[[xid]] <- xreview
    })
  shinyApp(
    ui = function(req) {
      # Fetch initial input state for content
      ui_reviews <- bind_rows(isolate(reactiveValuesToList(LATEST_REVIEWS)))
      tagList(
        app_resources(),
        f7Page(
          title = title,
          allowPWA = FALSE,
          options = app_pwa_options(),
          f7SingleLayout(
            navbar = f7Navbar(title = title, leftPanel = TRUE, rightPanel = TRUE),
            panels = tagList(mod_filter_panel("filter"), mod_search_panel("filter")),
            mod_explore_ui("explore", ui_reviews, content_meta)
          )
        )
      )
    },
    server = function(input, output, session) {
      # Returns list of filter settings
      filter_settings <- mod_filter_server("filter")
      # Styles content based on latest review
      # Shows/hides content/groups based on filter settings
      # Returns content_id of clicked content
      click_content <- mod_explore_server("explore", LATEST_REVIEWS, content_meta)
      # Shows content review popup and returns new review
      add_review <- mod_review_server("review", LATEST_REVIEWS, click_content)
      # Object to hold reviews submitted within the session
      SESSION_REVIEWS <- reactiveVal()
      # Add reviews to SESSION_REVIEWS as they are submitted
      # Also update LATEST_REVIEWS for sibling sessions
      observeEvent(add_review(), {
        new <- add_review()
        current <- SESSION_REVIEWS()
        updated <- bind_rows(current, new)
        SESSION_REVIEWS(updated)
        LATEST_REVIEWS[[new$content_id]] <- new
      })
      # Submit session reviews to callback when session ends
      onSessionEnded(function() {
        if (is.null(callback)) return()
        df <- isolate(SESSION_REVIEWS())
        callback(df)
      })
    },
    options = list(...)
  )
}

#' @importFrom shinyjs useShinyjs
app_resources <- function() {
  addResourcePath("www", app_sys("app/www"))
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "www/styles.css"),
    useShinyjs()
  )
}

app_pwa_options <- function() {
  list(
    theme = "auto",
    dark = FALSE, 
    skeletonsOnLoad = FALSE, 
    preloader = TRUE, 
    filled = FALSE, 
    color = "red",
    colors = list(
      primary = "#3D3D3D",
      red = "#ff3b30",
      green = "#4cd964",
      blue = "#2196f3",
      pink = "#ff2d55",
      yellow = "#ffcc00",
      orange = "#ff9500",
      purple = "#9c27b0",
      deeppurple = "#673ab7",
      lightblue = "#5ac8fa",
      teal = "#009688",
      lime = "#cddc39",
      deeporange = "#ff6b22",
      white = "#ffffff",
      black = "#000000"
    ),
    touch = list(
      touchClicksDistanceThreshold = 5, tapHold = TRUE,  tapHoldDelay = 750,
      tapHoldPreventClicks = TRUE,  iosTouchRipple = FALSE, mdTouchRipple = TRUE
    ),
    iosTranslucentBars = FALSE, 
    navbar = list(iosCenterTitle = TRUE, hideOnPageScroll = TRUE), 
    toolbar = list(hideOnPageScroll = FALSE),
    pullToRefresh = FALSE
  )
}
