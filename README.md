shiny.reviewer
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->
<!-- badges: end -->

### Overview

`shiny.reviewer` is an R package providing a configurable [shiny
app](https://shiny.posit.co/) that allows users to submit content
reviews and interactively filter and view content based on the most
recent review. The app can be used for different types of content, such
as educational courses, recipes, games, and books.

### Usage

To run a simple example, execute the following:

``` r
# Create and run ShinyReviewer
library(shiny.reviewer)
reviewer <- ShinyReviewer$new(
  reviews = REVIEWS_EXAMPLE, 
  content_meta = CONTENT_META_EXAMPLE,
  group_meta = GROUP_META_EXAMPLE
)
reviewer$run_app(title = "Mario Kart Wii Track Logger")
```

This creates and runs an application using the provided example content
(Mario Kart Wii tracks). This will work fine, but there is more work to
do if we want to synchronize data across application instances. This is
where `callback` comes in handy.

The below boilerplate code demonstrates an example strategy for
interfacing with a Google Sheets file. This is an ideal solution when
deploying to services like [shinyapps.io](https://shinyapps.io).

``` r
# Fetch configuration
OAUTH_CACHE <- ".secrets"
OAUTH_EMAIL <- ""
REVIEWS_SSID <- ""
REVIEWS_SHEET <- ""
# Authenticate and read Google Sheets file
library(googlesheets4)
options(gargle_oauth_cache = OAUTH_CACHE)
gs4_auth(email = OAUTH_EMAIL)
reviews <- read_sheet(ss = REVIEWS_SSID, sheet = REVIEWS_SHEET)
# Read custom metadata
content_meta <- read.csv("data/content_meta.csv")
group_meta <- read.csv("data/group_meta.csv")
# Create and run ShinyReviewer
library(shiny.reviewer)
reviewer <- ShinyReviewer$new(
  reviews = reviews, 
  content_meta = content_meta,
  group_meta = group_meta
)
reviewer$run_app(
  title = "Application Title",
  callback = function(df) {
    sheet_append(ss = REVIEWS_SSID, data = df, sheet = REVIEWS_SHEET)
  }
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