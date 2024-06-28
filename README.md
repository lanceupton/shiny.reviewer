shiny.reviewer
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->
<!-- badges: end -->

### Overview

`shiny.reviewer` is an R package providing a configurable [shiny
app](https://shiny.posit.co/) allowing users submit and interactively
filter and view content reviews. The app is designed to be accessed by
multiple simultaneous users, on mobile devices, with a synchronized
experience.

The package also includes helper methods to configure authentication for
Google Sheets, which enables persistent storage when deploying to
platforms like [shinyapps.io](https://shinyapps.io) or [Github
Pages](https://pages.github.com/).

A demo is available here:
[shiny-reviewer-demo](https://lanceupton.shinyapps.io/shiny-reviewer-demo)

### Usage

To install this package, execute the following:

``` r
remotes::install_github("lanceupton/shiny.reviewer")
```

To run a simple example, execute the following:

``` r
library(shiny.reviewer)
app_run(
  title = "Your Application Title",
  content_meta = CONTENT_META_EXAMPLE,
  reviews = REVIEWS_EXAMPLE, 
  group_meta = GROUP_META_EXAMPLE,
  launch.browser = TRUE
)
```

This runs an application using the provided example content (Mario Kart
Wii tracks). This will work fine, but you’ll probably want to record all
the reviews submitted by users. This is where `callback` comes in handy.
The below boilerplate code leverages the provided methods to sync
reviews to a Google Sheets file. It assumes that you have called
`DEV_auth_set()` to write an encrypted gs4 token to the project
directory.

``` r
library(shiny.reviewer)
library(gargle)
library(googlesheets4)
DEV_auth_get()
# Define Google sheets file ID and sheet here
REVIEWS_SSID <- Sys.getenv("REVIEWS_SSID")
REVIEWS_SHEET <- Sys.getenv("REVIEWS_SHEET")
# Read the Google Sheets file
reviews <- read_sheet(ss = REVIEWS_SSID, sheet = REVIEWS_SHEET)
# Read custom metadata
content_meta <- read.csv("data-raw/CONTENT_META.csv")
group_meta <- read.csv("data-raw/GROUP_META.csv")
# Run application
app_run(
  title = "Your Application Title",
  content_meta = content_meta,
  reviews = reviews, 
  group_meta = group_meta,
  # Append session reviews to the Google Sheets file
  callback = function(df) {
    sheet_append(ss = REVIEWS_SSID, data = df, sheet = REVIEWS_SHEET)
  },
  launch.browser = TRUE
)
```

### Features

**View Content**

The main interface includes a button for each content item, styled based
on the most recent review.

| Content Class                  | Content Preview                           |
|:-------------------------------|:------------------------------------------|
| Blacklisted (`blacklist=TRUE`) | ![](readme_files/content_blacklisted.png) |
| Top Rated (`rating=5`)         | ![](readme_files/content_5star.png)       |
| Unreviewed (`timestamp=NA`)    | ![](readme_files/content_unreviewed.png)  |
| All Other Content              | ![](readme_files/content_default.png)     |

Additionally, all content buttons display the emojis included within the
`notes` field of the most recent review.

**Filter Content**

The left sidebar includes an interface to filter content items based on
the most recent review.

The right sidebar includes an interface to search for content by title.

**Review Content**

A content button may be clicked to submit a review.

### Thanks

- [googlesheets4](https://googlesheets4.tidyverse.org/) - This makes it
  easy to implement persistent data storage in remote environments.

- [shinyMobile](https://rinterface.github.io/shinyMobile/) - This is so
  easy to use, and provides beautiful components.
