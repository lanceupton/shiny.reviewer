
app_sys <- function(...) {
  system.file(..., package = "shiny.reviewer")
}

#' @importFrom dplyr bind_rows
make_app_ui <- function(LATEST_REVIEWS, title, content_meta) {
  function(req) {
    reviews <- bind_rows(isolate(reactiveValuesToList(LATEST_REVIEWS)))
    tagList(
      app_resources(),
      f7Page(
        title = title,
        allowPWA = TRUE,
        options = app_pwa_options(),
        f7SingleLayout(
          navbar = f7Navbar(title = title, leftPanel = TRUE, rightPanel = TRUE),
          panels = tagList(mod_filter_panel("filter"), mod_search_panel("filter")),
          mod_explore_ui("explore", reviews, content_meta)
        )
      )
    )
  }
}

make_app_server <- function(LATEST_REVIEWS, content_meta, callback) {
  function(input, output, session) {
    # Returns list of filter settings
    filter_settings <- mod_filter_server("filter")
    # Styles/filters content and returns clicked content_id
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
    onSessionEnded(function() {
      if (is.null(callback)) return()
      df <- bind_rows(isolate(SESSION_REVIEWS()))
      callback(df)
    })
  }
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
