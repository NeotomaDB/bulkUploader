#' @title Convert CrossRef formatted data to Neotoma standard.
#' @description Using data pulled from the CrossRef API (documented
#' here: https://github.com/CrossRef/rest-api-doc#meta) use the `neotoma2`
#' publication format to store the records.
#' @export
#'
cr_to_neotoma <- function(crObject) {

  pubs <- map(crObject, function(x) {

    if (is.na(x)) {
      pubs <-  new("publication")
      return(pubs)
    } else {

        x[is.null(x)] <- NA_character_

        dateParse <- unlist(x$issued) %>%
          paste(collapse = '/') %>%
          lubridate::parse_date_time(c('Ym', 'Ymd'), quiet = TRUE)

        testNull <- function(val, out) {
          if(is.null(val)) { return(out)} else {return(val)}
        }

        makeAuthors <- new("authors",
                           authors = map(x$author, function(y) {
                            new("author",
                                author = new("contact",
                                             familyname =testNull(y$family, NA_character_),
                                             givennames= testNull(y$given, NA_character_)),
              order = 1)
          }))

        testNull <- function(val, out) {
          if(is.null(val)) { return(out)} else {return(val)}
        }

        for (j in names(x)) {
          if (length(x[[j]]) == 0) {
            x[[j]] <- ""
          }
        }

        pubs <- new("publication",
            publicationtype = testNull(x$type, NA_character_),
            publicationid = NA_integer_,
            articletitle = testNull(x$title[[1]], NA_character_),
            year = lubridate::year(dateParse) %>% as.character(),
            journal = testNull(x$`container-title`[[1]], NA_character_),
            volume = testNull(x$volume, NA_character_),
            issue = testNull(x$`journal-issue`$issue, NA_character_),
            pages = testNull(x$page, NA_character_),
            citation = makeCite(paste(pullAuth(makeAuthors), collapse = '; '),
                                lubridate::year(dateParse),
                                x$title,
                                x$`container-title`[[1]],
                                x$volume,
                                x$page),
            doi = testNull(x$DOI, NA_character_),
            author = makeAuthors)
    }
    return(pubs)
  }) %>%
    new("publications", publications = .)

  return(pubs)
}
