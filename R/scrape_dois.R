#' @title Scrape publication metadata from Crossref
#' @description Using publication information, retrieve a DOI and relevant publication information for a journal article.
#' @param x A formatted publication list for the CrossRef API.
#' @param n The number of records to return from CrossRef.  Default is 20, but in practice only about 3 records are needed for direct matching.
#' @param savefile A location for saving the (periodic) output from the CrossRef API.
#' @param restore Should the function look for an existing instance of the file?
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @import progress
#' @export
scrape_dois <- function(x, n = 20,
                        savefile = NA,
                        restore = TRUE) {

  x$rows = n
  x$sort="score"
  x$order="desc"

  pb <- progress::progress_bar$new(total=nrow(x))

  pullResult <- function(inp) {
    if('doi' %in% names(inp)) {
      if(is.na(inp$doi)) inp$doi <- NULL
    }
    if('doi' %in% names(inp)) {
      url <- paste0("https://api.crossref.org/works/", inp$doi)
      result <- httr::GET(url,
                          add_headers(mailto="neotomadb@gmail.com"),
                          user_agent("Neotoma Bulk Uploader v0.1 (https://github.com/NeotomaDB/bulkUploader)"))
    } else {
      url <- "https://api.crossref.org/works"
      result <- httr::GET(url,
                        query=inp,
                        add_headers(mailto="neotomadb@gmail.com"),
                        user_agent("Neotoma Bulk Uploader v0.1 (https://github.com/NeotomaDB/bulkUploader)"))
    }
    if (result$status_code == 200) {
      output <- httr::content(result)
      totres <- output$message$`total-results`
      if('items' %in% names(output$message)) {
        pubs <- output$message$items
      } else {
        pubs <- list(output$message)
      }
      
      return(pubs)
    } else {
      return(NULL)
    }
  }

  if(!is.na(savefile) & restore == TRUE) {
    output <- try(readRDS(savefile), silent = TRUE)
    if('try-error' %in% class(output)) {
      warning("Could not find savefile to restore from.  Generating new save file.")
      output <- list()
    }
  } else {
    output <- list()
  }

  for(i in (length(output) + 1):nrow(x)) {
    pb$tick()
    output[[i]] <- pullResult(as.list(data.frame(x[i,])))
    cat(i)
    if(!is.na(savefile)) {
      saveRDS(output, savefile)
    }
  }
  return(output)
}
