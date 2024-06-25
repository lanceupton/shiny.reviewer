
mod_review_server <- function(id, RV_REVIEWS, click_content) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    observeEvent(click_content(), {
      xid <- click_content()
      review <- RV_REVIEWS[[xid]]
      f7Popup(
        id = shiny:::createUniqueId(8),
        title = review$content_id,
        swipeToClose = TRUE,
        f7Block(
          tags$p(tags$strong("Last Reviewed:"), friendly_timestamp(review$timestamp) %||% "Never :(")
        ),
        f7List(
          f7Toggle(
            inputId = ns("blacklist"),
            label = "Blacklist Track?",
            checked = isTRUE(review$blacklist)
          ),
          f7Stepper(
            inputId = ns("rating"),
            label = "Rating:",
            min = 1,
            max = 5,
            value = review$rating %||% 3
          ),
          f7Stepper(
            inputId = ns("difficulty"),
            label = "Difficulty:",
            min = 1,
            max = 3,
            value = review$difficulty %||% 2
          ),
          f7TextArea(
            inputId = ns("notes"),
            label = "Notes:",
            value = review$notes %||% ""
          )
        ),
        tags$br(),
        tagAppendAttributes(
          tag = f7Button(
            inputId = ns("btn_save"),
            label = "Save Review"
          ),
          class = "popup-close"
        )
      )
    })
    eventReactive(input$btn_save, {
      format_reviews(data.frame(
        content_id = click_content(),
        timestamp = Sys.time(),
        rating = input$rating,
        difficulty = input$difficulty,
        blacklist = input$blacklist,
        notes = input$notes
      ))
    })
  })
}
