#' @title

matchPubs <- function(cross, pubs, results) {
  bestMatch <- list()

  for(i in 1:length(cross)) {
    bestMatch[[i]] <- findMatch(pubs[i],
                                results[[i]],
                                cross[[i]])
    if (!('publication' %in% class(bestMatch[[i]]) | is.na(bestMatch[[i]]))) {
      bestMatch[[i]] <- NULL
      break
    }
  }
  return(bestMatch)
}
