
mod_filter_panel <- function(id, side = "left") {
  ns <- NS(id)
  f7Panel(
    id = ns("filter_panel"),
    title = "Content Filters",
    side = side,
    f7List(
      f7Toggle(
        inputId = ns("unreviewed"),
        label = "Unreviewed?"
      ),
      conditionalPanel(
        ns = ns,
        condition = "input.unreviewed!=true",
        f7Toggle(
          inputId = ns("blacklist"),
          label = "Blacklisted?"
        ),
        f7Slider(
          inputId = ns("rating"),
          label = "Rating:",
          min = 1,
          max = 5,
          value = c(1, 5)
        ),
        f7Slider(
          inputId = ns("difficulty"),
          label = "Difficulty:",
          min = 1,
          max = 3,
          value = c(1, 3)
        ),
        f7Text(
          inputId = ns("tags"),
          label = "Tags:"
        )
      ),
      f7Block(f7Button(
        inputId = ns("btn_filter"),
        label = "Apply Filters"
      )),
      f7Block(f7Button(
        inputId = ns("btn_reset"),
        label = "Reset Filters"
      ))
    )
  )
}

mod_search_panel <- function(id, side = "right") {
  ns <- NS(id)
  f7Panel(
    id = ns("search_panel"),
    title = "Content Title Search",
    side = side,
    f7List(
      f7Text(
        inputId = ns("title_pattern"),
        label = "Title search:"
      ),
      f7Block(f7Button(
        inputId = ns("btn_search"),
        label = "Search Content"
      ))
    )
  )
}

#' @importFrom shinyjs reset
mod_filter_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    settings_out <- reactiveValues(
      type = NULL,
      title_pattern = NULL,
      unreviewed = FALSE,
      blacklist = FALSE,
      rating = c(1, 5),
      difficulty = c(1, 3),
      tags = NULL
    )
    observeEvent(input$btn_reset, {
      updateF7Toggle("unreviewed", checked = FALSE)
      updateF7Toggle("blacklist", checked = FALSE)
      updateF7Slider("rating", value = c(1, 5))
      updateF7Slider("difficulty", value = c(1, 3))
      updateF7Text("tags", value = "")
      settings_out$type <- NULL
      updateF7Panel("filter_panel")
    })
    observeEvent(input$btn_filter, {
      settings_out$type <- "filter"
      settings_out$unreviewed <- input$unreviewed
      settings_out$blacklist <- input$blacklist
      settings_out$rating <- input$rating
      settings_out$difficulty <- input$difficulty
      settings_out$tags <- input$tags
      updateF7Panel("filter_panel")
    })
    observeEvent(input$btn_search, {
      settings_out$type <- "search"
      settings_out$title_pattern <- input$title_pattern
      updateF7Panel("search_panel")
    })
    reactive(reactiveValuesToList(settings_out))
  })
}

FILTER_FUN <- function(df, settings) {
  if (is.null(settings$type)) return(seq(nrow(df)))
  if (settings$type == "filter") {
    if (isTRUE(settings$unreviewed)) {
      which(is.na(df$timestamp))
    } else {
      i1 <- which(df$blacklist == settings$blacklist)
      i2 <- which(df$rating %in% seq(settings$rating[1], settings$rating[2]))
      i3 <- which(df$difficulty %in% seq(settings$difficulty[1], settings$difficulty[2]))
      if (!isTruthy(settings$tags)) {
        i4 <- seq(nrow(df))
      } else {
        tags_pattern <- paste0(strsplit(settings$tags, "")[[1]], collapse = "|")
        i4 <- grep(tags_pattern, df$notes, perl = TRUE)
      }
      Reduce(intersect, list(i1, i2, i3, i4))
    }
  } else if (settings$type == "search") {
    grep(settings$title_pattern, df$track, ignore.case = TRUE)
  }
}
