library(shiny)
library(R6)

test1_ui <- function(id) {
  ns <- NS(id)
  tagList(
    textInput(ns("user_input"), "Enter some text:", ""),
    actionButton(ns("submit_btn"), "Submit"),
    actionButton(ns("clear_btn"), "Clear"),
    verbatimTextOutput(ns("txt"))
  )
}

test1_server <- function(id, val) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    observeEvent(input$submit_btn, {
      val[["test1"]] <- input$user_input
    })
    observeEvent(input$clear_btn, {
      val[["test1"]] <- NULL
    })
    output$txt <- renderText({
      val[["test1"]]
    })
  })
}

AppClass <- R6Class(
  "AppClass",
  private = list(
    reactive_store = NULL
  ),
  public = list(
    initialize = function() {
      private$reactive_store <- reactiveValues()
    },
    run_app = function() {
      ui <- fluidPage(
        test1_ui("test1")
      )
      server <- function(input, output, session) {
        test1_server("test1", private$reactive_store)
      }
      shinyApp(ui = ui, server = server, options = list(launch.browser = TRUE))
    }
  )
)

# Example usage:
app <- AppClass$new()
app$run_app()
