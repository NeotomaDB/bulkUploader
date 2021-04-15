#' @title Get scores from CrossRef results
#' @description Pulls scores from \code{scrape_doi()}
#' @importFrom purrr map
#' @export
get_cr_results <- function(x) {
  if (length(x) > 0) {
    scores = unlist(map(x, function(z) { z$score }))
    output <- data.frame(scores = scores,
                         diff = c(-diff(scores), 0))
  } else {
    output <- data.frame(scores = NA,
                         diff = NA)
  }
  return(output)
}
