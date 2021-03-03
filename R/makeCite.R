#' @title Make Citation for comparing publication matches.
#' @description Takes in a set of fields and concatenates them using a period.  Really simple.
#' @export
makeCite <- function(x, ...) {
  paste(x, ..., sep = ". ")
}

#' @export
pullAuth <- function(x) {
  x@authors %>%
    map(function(y) paste(y@author@familyname, y@author@givennames, sep=', ')) %>%
    unlist()
}
