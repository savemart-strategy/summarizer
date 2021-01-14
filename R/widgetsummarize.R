#' Show a single summary statistic in a widget
#'
#' A `widgetsummarize` displays a single statistic derived from a linked table.
#' Its primary use is with the `crosstalk` package. Used with `crosstalk`,
#' a `widgetsummarize` displays a value which updates as the data selection
#' changes. For percentages and weighted average summaries, provide parameters 'statistic2'
#' and 'column2'.
#'
#' @param data Data to summarize, normally an instance of [crosstalk::SharedData].
#' @param statistic The statistic to compute.
#' @param column For `sum` and `mean` statistics, the column of `data` to summarize.
#' Not used for `count` statistic.
#' @param statistic2 Optional. If provided, summarises parameter `column2`, which becomes
#' a denominator of `column`.
#' @param column2 For `sum` and `mean` statistics, the column of `data` to summarize.
#' Not used for `count` statistic.
#' @param selection Expression to select a fixed subset of `data`. May be
#' a logical vector or a one-sided formula that evaluates to a logical vector.
#' If used, the `key` given to [crosstalk::SharedData] must be a fixed column (not row numbers).
#' @param digits Number of decimal places to display, or NULL to display full precision.
#'
#' @import crosstalk
#' @import htmlwidgets
#'
#' @export
#' @seealso \url{https://kent37.github.io/summarywidget}
widgetsummarize <- function(data,
                          statistic=c("count", "sum", "mean"), column = NULL,
                          statistic2=c("count", "sum", "mean", NULL), column2 = NULL,
                          selection=NULL, digits=0,
                          width=NULL, height=NULL, elementId = NULL) {

  if (crosstalk::is.SharedData(data)) {
    # Using Crosstalk
    key <- data$key()
    group <- data$groupName()
    data <- data$origData()
  } else {
    # Not using Crosstalk
    warning("summarywidget works best when data is an instance of crosstalk::SharedData.")
    key <- NULL
    group <- NULL
  }

  statistic <- match.arg(statistic)
  statistic2 <- match.arg(statistic2)

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

  # We just need one column, either the row.names or the specified column.
  if (is.null(column)) {
    if (statistic != 'count')
      stop("Column must be provided with ", statistic, " statistic.")
    data = row.names(data)
  } else {
    if (!(column %in% colnames(data)))
      stop("No ", column, " column in data.")
    #data = data[[column]]
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
      crosstalk_key = key,
      crosstalk_group = group
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'widgetsummarize',
    x,
    width = width,
    height = height,
    package = 'widgetsummarize',
    elementId = elementId,
    dependencies = crosstalk::crosstalkLibs()
  )
}
