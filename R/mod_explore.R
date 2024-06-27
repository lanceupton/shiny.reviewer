
#' @importFrom dplyr filter group_map rowwise
mod_explore_ui <- function(id, reviews, content_meta) {
  ns <- NS(id)
  # Create a content button for each content_id
  rowwise(content_meta) |>
    group_map(function(x, k) {
      xid <- x$id
      xreview <- filter(reviews, content_id == xid)
      mod_content_btn(ns(make.names(xid)), xreview, x$title)
    })
}

#' @importFrom dplyr group_map rowwise
mod_explore_server <- function(id, reviews, content_meta) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    click_content <- reactiveVal()
    click_trigger <- reactiveVal()
    rowwise(content_meta) |>
      group_map(function(x, key) {
        xid <- x$id
        click <- mod_content_server(make.names(xid), xid, x$title, reviews)
        observeEvent(click(), {
          click_content(xid)
          click_trigger(Sys.time())
        })
      })
    eventReactive(click_trigger(), click_content())
  })
}

mod_content_btn <- function(id, review, title) {
  ns <- NS(id)
  tagAppendAttributes(
    tag = f7Button(
      inputId = ns("btn_open"),
      label = make_content_label(title, review)
    ),
    class = determine_content_class(review)
  )
}

determine_content_class <- function(review) {
  all_classes <- c("content_blacklisted", "content_5star", "content_unreviewed", "content_default")
  ifelse(
    test = isTRUE(review$blacklist),
    yes = all_classes[1],
    no = ifelse(
      test = isTRUE(review$rating == 5),
      yes = all_classes[2],
      no = ifelse(
        test = !isTruthy(review$timestamp),
        yes = all_classes[3],
        no =  all_classes[4]
      )
    )
  )
}

make_content_label <- function(title, review) {
  emojis <- extract_emojis(review$notes)
  ifelse(
    test = isTruthy(emojis),
    yes = paste(c(title, emojis), collapse = " "),
    no = title
  )
}

#' @importFrom shinyjs addClass removeClass
mod_content_server <- function(id, content_id, title, reviews) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    observeEvent(reviews[[content_id]], {
      review <- reviews[[content_id]]
      add_class <- determine_content_class(review)
      all_classes <- c("content_blacklisted", "content_5star", "content_unreviewed", "content_default")
      rm_class <- paste0(setdiff(all_classes, add_class), collapse = " ")
      addClass("btn_open", add_class)
      removeClass("btn_open", rm_class)
      updateF7Button(inputId = "btn_open", label = make_content_label(title, review))
    }, ignoreInit = TRUE)
    reactive(input$btn_open)
  })
}
