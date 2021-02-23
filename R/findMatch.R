#' @title A simple user-guided match function.
#' @description Using a guiding text citation, and information about match
#' scores from CrossRef, guide the user to match (or not) a publication.
#' @export

findMatch <- function(valid, scores, test) {

  if (length(test@publications) > 0) {
    cat("Citation to match:\n")
    cat(valid)
    cat('\n', sprintf('** Best match score: %.1f; Next match (delta): -%.1f **', scores[1], scores[2]), '\n')
    cat('==Best Match==\n')
    cat(test@publications[[1]]@citation, '\n')
    if (length(test@publications) > 1) {
      cat('===Next Match===\n')
      cat(test@publications[[2]]@citation, '\n')
    }

    works <- ''

    while (! works %in% c('y','n', 'c')) {
      works <- readline("Accept *best* match? (y/n [c to cancel]) > ") %>%
        tolower()
    }

    output <- switch(works,
                     y = test@publications[[1]],
                     n = NA,
                     c = "break")
    return(output)
  } else {
    return(NA)
  }

}