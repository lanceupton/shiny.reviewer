
#' ShinyReviewer R6 Class.
#' 
#' Use this to create ShinyReviewer application instances.
#' 
#' @export
ShinyReviewer <- R6::R6Class(
  classname = "ShinyReviewer",
  private = list(
    LATEST_REVIEWS = NULL,
    content_meta = NULL,
    group_meta = NULL
  ),
  public = list(
    
    #' @description Create a ShinyReviewer object.
    #' 
    #' @param reviews A data frame with `content_id`, `timestamp`, `rating`,
    #'   `difficulty`, `blacklist`, and `notes`. The row with the most recent
    #'   `timestamp` is used for each `content_id`.
    #' @param content_meta A data frame with `group_id` (optional), `id`, and
    #'   `title`. If `group_id` is provided, content is grouped within cards.
    #' @param group_meta (Optional) A df giving `id`, `title`, and `img_src`,
    #'   used to create group cards.
    #' 
    #' @import shiny
    #' @import shinyMobile
    #' @importFrom dplyr filter group_walk rowwise
    initialize = function(reviews, content_meta, group_meta) {
      reviews <- format_reviews(reviews, latest = TRUE)
      private$LATEST_REVIEWS <- reactiveValues()
      private$content_meta <- format_content_meta(content_meta)
      private$group_meta <- format_group_meta(group_meta)
      rowwise(private$content_meta) |>
        group_walk(function(df, key) {
          xid <- df$id
          xreview <- filter(reviews, content_id == xid)
          private$LATEST_REVIEWS[[xid]] <- xreview
        })
    },
    
    #' @description Run the ShinyReviewer application.
    #' 
    #' @param title An application title.
    #' @param callback (Optional) A `function(df)` to do something with the
    #'   reviews submitted within a session when it ends.
    #' @param ... Options passed to `shiny::shinyApp()`
    run_app = function(title, callback = NULL, ...) {
      shinyApp(
        ui = make_app_ui(private$LATEST_REVIEWS, title, private$content_meta),
        server = make_app_server(private$LATEST_REVIEWS, private$content_meta, callback),
        options = list(...)
      )
    }
    
  )
)
