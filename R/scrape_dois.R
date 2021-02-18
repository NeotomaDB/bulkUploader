#' @title Scrape publication metadata from Crossref
#' @description Using publication information, retrieve a DOI and relevant publication information for a journal article.
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
scrape_dois <- function(title, year, n = 20) {
  url <- "https://api.crossref.org/works"

  year <-  stringr::str_extract(year, "\\d*")
  filters <- paste0(paste0("from-pub-date:", year), ",",
                    paste0("until-pub-date:", year))

  result <- httr::GET(url,
                      query=list(query.bibliographic = title,
                                 sort = "score",
                                 order="desc",
                                 rows = n,
                                 filter=filters))
  if (result$status_code == 200) {
    output <- httr::content(result)
    totres <- output$message$`total-results`
    pubs <- output$message$items
    return(pubs)
  } else {
    message("No matched publications.")
    return(NULL)
  }
}
