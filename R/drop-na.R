#' Drop rows containing missing values
#'
#' @param data A data frame.
#' @inheritSection gather Rules for selection
#' @inheritParams gather
#' @examples
#' library(dplyr)
#' df <- tibble(x = c(1, 2, NA), y = c("a", NA, "b"))
#' df %>% drop_na()
#' df %>% drop_na(x)
#' @export
drop_na <- function(data, ...) {
  UseMethod("drop_na")
}
#' @export
drop_na.default <- function(data, ...) {
  drop_na_(data, vars = compat_as_lazy_dots(...))
}
#' @export
drop_na.data.frame <- function(data, ...) {
  vars <- unname(tidyselect::vars_select(colnames(data), ...))
  if (!is_character(vars)) {
    abort("`vars` is not a character vector.")
  }

  if (is_empty(vars)) {
    f <- complete_cases(data)
  } else {
    f <- complete_cases(data[vars])
  }
  out <- data[f, , drop = FALSE]

  reconstruct_tibble(data, out)
}

# copied from ggplot2
# TODO: reimplement in C roughly following complete.cases() C backend
# https://github.com/wch/r-source/blob/master/src/library/stats/src/complete_cases.c
complete_cases <- function(x, fun) {
  ok <- vapply(x, is_complete, logical(nrow(x)))

  # Need a special case test when x has exactly one row, because rowSums
  # doesn't respect dimensions for 1x1 matrices. vapply returns a vector (not
  # a matrix when the input has one row.
  if (is.vector(ok)) {
    all(ok)
  } else {
    # Find all the rows where all are TRUE
    rowSums(as.matrix(ok)) == ncol(x)
  }
}

is_complete <- function(x) {
  if (typeof(x) == "list") {
    !vapply(x, is.null, logical(1))
  } else {
    !is.na(x)
  }
}


#' @rdname deprecated-se
#' @export
drop_na_ <- function(data, vars) {
  UseMethod("drop_na_")
}
#' @export
drop_na_.data.frame <- function(data, vars) {
  drop_na(data, !!! vars)
}
