# widgetsummarize
Allows [crosstalk](https://rstudio.github.io/crosstalk/) multi-column summarization for [flexdashboard](https://rmarkdown.rstudio.com/flexdashboard/) projects

This is an improved version of the [summarywidget](https://kent37.github.io/summarywidget/) package. It solves the limitation of not being able to summarize percentages, weighted average numbers or any calculation that divides two numbers.
It adds the parameters **column2** and **statistic2**. Result is a span containing the division of **column** summarized using the function defined in **statistic** by **column2** summarized using the function defined in **statistic2**.

- Usage
```
#install
devtools::install_github('savemart-strategy/widgetsummarize')

#load package
library(widgetsummarize)
```

- Example
```
library(crosstalk)

#create crosstalk SharedData object
sh_df <- SharedData$new(iris)

bscols(
  #dropbox selector
  filter_select('species', 'Species', sh_df, ~Species),
  #result
  paste0("Result of Sepal.Length / Sepal.Width: "),
  widgetsummarize(sh_df, 
                  statistic = 'sum', column = 'Sepal.Length', 
                  statistic2 = 'sum', column2 = 'Sepal.Width',
                  digits = 2)
)
```
