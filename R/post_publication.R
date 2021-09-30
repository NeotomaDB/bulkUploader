#' @export
post_publication <- function(cred, publication, dev=TRUE) {
    checkCred <- checkCredentials(cred)
    
    pub <- as.data.frame(publication)
    if(!is.na(pub$publicationid)) {
        warning("This publication is already in Neotoma.  Modify the content using Tilia.")
    } else {
        if(checkCred@valid == TRUE) {
            # The user is valid and it's not in the DB.
            baseurl <- ifelse(dev, "https://tilia-dev.neotomadb.org/api/update/write", "https://tilia.neotomadb.org/api/update/write")

            headers = list(username = cred@username, pwd = cred@password)
            query = list(method = "ts.insertpublication",
                        data=list(
                             `_pubtypeid` = publication@publicationtypeid,
                             `_year`  = publication@year,
                             `_citation` =  publication@citation,
                             `_title` =  publication@articletitle,
                             `_journal` =  publication@journal,
                             `_vol` =  publication@volume,
                             `_issue` =  publication@issue,
                             `_pages` =  publication@pages,
                             `_citnumber` =  publication@citationnumber,
                             `_doi` =  publication@doi,
                             `_booktitle` =  publication@booktitle,
                             `_numvol` =  publication@numvolumes,
                             `_edition` =  publication@edition,
                             `_voltitle` =  publication@volumetitle,
                             `_sertitle` =  publication@seriestitle,
                             `_servol` =  publication@seriesvolume,
                             `_publisher` =  publication@publisher,
                             `_url` =  publication@url,
                             `_city` =  publication@city,
                             `_state` =  publication@state,
                             `_country` =  publication@country,
                             `_origlang` =  publication@originallanguage,
                             `_notes` =  publication@notes))

            for(i in length(query$data):1) {
                if(is.na(query$data[[i]])) {
                    query$data[[i]] <- NULL
                }
            }

            pushpub <- httr::POST(baseurl, 
                                  body=query, 
                                  encode="json",
                                  add_headers(username = cred@username, pwd = cred@password))
        }
    }
}