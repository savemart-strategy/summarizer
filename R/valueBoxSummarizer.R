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
#' @import htmltools
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
                           htmltools::tags$script(htmltools::HTML(
"window.FlexDashboardComponents.push({

  type: 'custom',

  find: function(container) {
    if (container.find('span.value-summarywidget-output').length)
      return container;
    else
      return $();
  },

  flex: function(fillPage) {
    return false;
  },

  layout: function(title, container, element, fillPage) {

    // alias variables
    var chartTitle = title;
    var valueBox = element;

    // add value-box class to container
    container.addClass('value-box');

    // value paragraph
    var value = $('<p class=\"value\"></p>');

    // if we have shiny-text-output then just move it in
    var valueOutputSpan = [];
    var shinyOutput = valueBox.find('.shiny-valuebox-output').detach();
    var summaryOutput = valueBox.find('.summarizer').detach();

    if (shinyOutput.length) {
      valueBox.children().remove();
      shinyOutput.html('&mdash;');
      value.append(shinyOutput);
    }

    if (summaryOutput.length) {
      value.append(summaryOutput);
      valueOutputSpan = valueBox.find('span.value-summarywidget-output')
    }

    // caption
    var caption = $('<p class=\"caption\"></p>');
    caption.append(chartTitle);

    // build inner div for value box and add it
    var inner = $('<div class=\"inner\"></div>');
    inner.append(value);
    inner.append(caption);
    valueBox.append(inner);

    // add icon if specified
    var icon = $('<div class=\"icon\"><i></i></div>');
    valueBox.append(icon);
    function setIcon(chartIcon) {
      var iconLib = '';
      var iconSplit = chartIcon.split(' ');
      if (iconSplit.length > 1) {
        iconLib = iconSplit[0];
        chartIcon = iconSplit.slice(1).join(' ');
      } else {
        var components = chartIcon.split('-');
        if (components.length > 1)
          iconLib = components[0];
      }
      icon.children('i').attr('class', iconLib + ' ' + chartIcon);
    }
    var chartIcon = valueBox.attr('data-icon');
    if (chartIcon)
      setIcon(chartIcon);

    // set color based on data-background if necessary
    var dataBackground = valueBox.attr('data-background');
    if (dataBackground)
      valueBox.css('background-color', bgColor);
    else {
      // default to bg-primary if no other background is specified
      if (!valueBox.hasClass('bg-primary') &&
          !valueBox.hasClass('bg-info') &&
          !valueBox.hasClass('bg-warning') &&
          !valueBox.hasClass('bg-success') &&
          !valueBox.hasClass('bg-danger')) {
        valueBox.addClass('bg-primary');
      }
    }

    // handle data attributes in valueOutputSpan
    function handleValueOutput(valueOutput) {

      // caption
      var dataCaption = valueOutput.attr('data-caption');
      if (dataCaption)
        caption.html(dataCaption);

      // icon
      var dataIcon = valueOutput.attr('data-icon');
      if (dataIcon)
        setIcon(dataIcon);

      // color
      var dataColor = valueOutput.attr('data-color');
      if (dataColor) {
        if (dataColor.indexOf('bg-') === 0) {
          valueBox.css('background-color', '');
          if (!valueBox.hasClass(dataColor)) {
             valueBox.removeClass('bg-primary bg-info bg-warning bg-danger bg-success');
             valueBox.addClass(dataColor);
          }
        } else {
          valueBox.removeClass('bg-primary bg-info bg-warning bg-danger bg-success');
          valueBox.css('background-color', dataColor);
        }
      }

      // url
      var dataHref = valueOutput.attr('data-href');
      if (dataHref) {
        valueBox.addClass('linked-value');
        valueBox.off('click.value-box');
        valueBox.on('click.value-box', function(e) {
          window.FlexDashboardUtils.showLinkedValue(dataHref);
        });
      }
    }

    // check for a valueOutputSpan
    if (valueOutputSpan.length > 0) {
      handleValueOutput(valueOutputSpan);
    }

    // if we have a shinyOutput then bind a listener to handle
    // new valueOutputSpan values
    shinyOutput.on('shiny:value',
      function(event) {
        var element = $(event.target);
        setTimeout(function() {
          var valueOutputSpan = element.find('span.value-output');
          if (valueOutputSpan.length > 0)
            handleValueOutput(valueOutputSpan);
        }, 10);
      }
    );
  }
});
")))

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
