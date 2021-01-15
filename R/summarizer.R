#' Show summary statistic in a widget
#'
#' A `summarizer` displays statistic derived from a linked table.
#' Its primary use is with the `crosstalk` package. Used with `crosstalk`,
#' a `summarizer` displays a value which updates as the data selection
#' changes. It summarizes one-dimentional as well as two-dimensional data when `column2`
#' and `statistic2` is provided
#'
#' @param data Data to summarize, normally an instance of [crosstalk::SharedData].
#' @param statistic The statistic to compute.
#' @param column For `sum` and `mean` statistics, the column of `data` to summarize.
#' Not used for `count` statistic.
#' @param statistic2 Optional. If provided, summarises parameter `column2`, which becomes
#' a denominator of `column`.
#' @param column2 Optional. For `sum` and `mean` statistics, the column of `data` to summarize.
#' Not used for `count` statistic.
#' @param selection Expression to select a fixed subset of `data`. May be
#' a logical vector or a one-sided formula that evaluates to a logical vector.
#' If used, the `key` given to [crosstalk::SharedData] must be a fixed column (not row numbers).
#' @param digits Number of decimal places to display, or NULL to display full precision.
#' @param prefix text to be placed before the result number (e.g '$').
#' @param suffix text to be placed after the result number (e.g '%', '/month').
#' @param elementId custom HTML ID for the returning widget.
#'
#' @import crosstalk
#' @import htmlwidgets
#'
#' @export
summarizer <- function(data,
                          statistic=c("count", "sum", "mean"), column = NULL,
                          statistic2=c("count", "sum", "mean", NULL), column2 = NULL,
                          selection=NULL, digits=0, prefix=NULL, suffix=NULL,
                          width=NULL, height=NULL, elementId = NULL) {

  #validate statitic arguments
  statistic <- match.arg(statistic)
  statistic2 <- match.arg(statistic2)

  #crosstalk keys and group
  if (crosstalk::is.SharedData(data)) {
    # Using Crosstalk
    key <- data$key()
    group <- data$groupName()
    data <- data$origData()
  } else {
    # Not using Crosstalk
    warning("summarizer works best when data is an instance of crosstalk::SharedData.")
    key <- NULL
    group <- NULL
  }

  #validate colummn arguments
  if (is.null(column)) {
    if (statistic != 'count')
      stop("Column must be provided with ", statistic, " statistic.")
    data = row.names(data)
  } else {
    if (!(column %in% colnames(data)))
      stop("No ", column, " column in data.")
  }

  # if((is.null(statistic2) & !is.null(column2)) | (!is.null(statistic2) & is.null(column2))) {
  #   stop("Column2 must be provided with statistic2")
  # }

  # If selection is given, apply it
  if (!is.null(selection)) {
    # Evaluate any formula
    if (inherits(selection, 'formula')) {
      if (length(selection) != 2L)
        stop("Unexpected two-sided formula: ", deparse(selection))
      selection = eval(selection[[2]], data, environment(selection))
    }

    if (!is.logical(selection))
      stop("Selection must contain TRUE/FALSE values.")
    data = data[selection,]
    key = key[selection]
  }

  if (is.null(prefix)) {
    prefix = ''
  }
  if (is.null(suffix)) {
    suffix = ''
  }

  # forward options using x
  x = list(
    data = data,
    settings = list(
      statistic = statistic,
      statistic2 = statistic2,
      column = column,
      column2 = column2,
      digits = digits,
      prefix = prefix,
      suffix = suffix,
      crosstalk_key = key,
      crosstalk_group = group
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'summarizer',
    x,
    width = width,
    height = height,
    package = 'summarizer',
    elementId = elementId,
    dependencies = crosstalk::crosstalkLibs()
  )
}
