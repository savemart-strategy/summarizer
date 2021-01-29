#' Crates a Flexdashboard-like valuebox for object returned by [summarizer()] function
#'
#' A `summarizer` displays statistic derived from a linked table.
#' Its primary use is with the `crosstalk` package. Used with `crosstalk`,
#' a `summarizer` displays a value which updates as the data selection
#' changes. It summarizes one-dimentional as well as two-dimensional data when `column2`
#' and `statistic2` is provided
#'
#' @param value string, numeric value or span object returned by [summarizer()].
#' @param caption text placed on the bottom of the valuebox.
#' @param icon class of a font-awesome icon. Visit: fontawesome.com for more info.
#' @param color background color of the valuebox.
#' @param href hyperlink string.
#'
#' @import crosstalk
#' @import htmlwidgets
#'
#' @export

valueBoxSummarizer <- function (value, caption = NULL,
                                icon = NULL, color = NULL, href = NULL) {

  if (!is.null(color) && color %in% c("primary", "info", "success",
                                      "warning", "danger"))
    color <- paste0("bg-", color)

  valueOutput <- tags$span(class = "value-summarywidget-output",
                           `data-caption` = caption,
                           `data-icon` = icon,
                           `data-color` = color,
                           `data-href` = href,
                           value,
                           tags$script(src = "./inst/htmlwidgets/lib/valueboxSummarizer.js"))

  hasPrefix <- function(x, prefix) {
    if (!is.null(x))
      grepl(paste0("^", prefix), x)
    else FALSE
  }

  fontAwesome <- hasPrefix(icon, "fa")
  ionicons <- hasPrefix(icon, "ion")
  deps <- flexdashboard:::html_dependencies_fonts(fontAwesome, ionicons)
  if (length(deps) > 0)
    valueOutput <- attachDependencies(valueOutput, deps)
  valueOutput
}
