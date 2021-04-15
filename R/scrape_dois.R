#' @title Scrape publication metadata from Crossref
#' @description Using publication information, retrieve a DOI and relevant publication information for a journal article.
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @import progress
scrape_dois <- function(x, n = 20, savefile = NA, restore = TRUE) {

  x$rows = n
  x$sort="score"
  x$order="desc"

  pb <- progress::progress_bar$new(total=nrow(x))

  pullResult <- function(inp) {
    url <- "https://api.crossref.org/works"
    result <- httr::GET(url,
                      query=inp)

    if (result$status_code == 200) {
      output <- httr::content(result)
      totres <- output$message$`total-results`
      pubs <- output$message$items
      return(pubs)
    } else {
      return(NULL)
    }
  }

  if(!is.na(savefile) & restore == TRUE) {
    output <- tryCatch(readRDS(savefile),
                       error={stop("Could not find savefile to restore from.")})
  } else {
    output <- list()
  }

  for(i in (length(output) + 1):nrow(x)) {
    pb$tick()
    output[[i]] <- pullResult(as.list(data.frame(x[i,])))
    if(!is.na(savefile)) {
      saveRDS(output, savefile)
    }
  }
  return(output)
}
