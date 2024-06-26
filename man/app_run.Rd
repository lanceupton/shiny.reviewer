% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/app.R
\name{app_run}
\alias{app_run}
\title{Run the Shiny Application.}
\usage{
app_run(
  title,
  content_meta,
  reviews = NULL,
  group_meta = NULL,
  callback = NULL,
  public_proof = FALSE,
  ...
)
}
\arguments{
\item{title}{An application title.}

\item{content_meta}{A data frame with \code{group_id} (optional), \code{id}, and
\code{title}. If \code{group_id} is provided, content is grouped within cards.}

\item{reviews}{(Optional) A data frame with \code{content_id}, \code{timestamp},
\code{rating}, \code{difficulty}, \code{blacklist}, and \code{notes}.}

\item{group_meta}{(Optional) A data frame with \code{id}, \code{title}, and \code{img_src},
used to create group cards.}

\item{callback}{(Optional) A \verb{function(df)} to do something with the
reviews submitted within a session when it ends.}

\item{public_proof}{(default FALSE) If TRUE, don't record user text input.}

\item{...}{Options passed to \code{shiny::shinyApp()}}
}
\description{
Run the Shiny Application.
}
