#' @title Format publication table
#' @description Takes an unstructured set of publications to be imported into the DOI scraper.  
#' In cases where more than one column is provided (as \code{c('columnOne', 'columnTwo')}) the 
#' columns in the \code{data.frame()} will be \code{coalesce()}d into a single vector, replacing 
#' \code{NA} values with information from one or the other filled column.  If both columns contain 
#' information, then the \em{first} column with information will be used.
#' @x A \code{data.frame()} with publication information from a particular database.
#' @title The (optional) column or columns in \code{x} that are associated with the publication title.
#' @author The (optional) column (or columns) with author information.
#' @editor The (optional) column (or columns) with editor information.
#' @year The (optional) column (or columns) with publicaiton year information.
#' @citation The full text citation for the publication.
#' @importFrom dplyr coalesce
#' @examples
#' data(miomapcsv)
#' crossFormat <- formatPubs(miomapcsv, author='Author', year='Year', title=c('Title', 'Book.Title'))
#' results <- scrape_dois(crossFormat)
#' @export
formatPubs <- function(x, title=NULL, author=NULL, year = NULL, editor=NULL, citation=NULL) {
    output <- list()
    
    if (!is.null(title)) {
        if(length(title) == 1) {
            output[['title']] <- unlist(x[,title])
        } else {
            output[['title']] <- coalesce(!!!x[,title])
        }
    }
    
    if (!is.null(editor)) {
        if(length(editor) == 1) {
            output[['query.editor']] <- unlist(x[,editor])
        } else {
            output[['query.editor']] <- coalesce(!!!x[,editor])
        }
    }
    
    if (!is.null(author)) {
        if(length(author) == 1) {
            output[['query.author']] <- unlist(x[,author])
        } else {
            output[['query.author']] <- coalesce(!!!x[,author])
        }
    }
    
    if (!is.null(year)) {
        if(length(year) == 1) {
            output[['filter']]  <- paste0('from-print-pub-date:',unlist(x[,year]),
                                          ',until-print-pub-date:',unlist(x[,year]))
        } else {
            year <- coalesce(!!!x[,year])
            paste0('from-print-pub-date:',year, ',until-print-pub-date:',year)
        }
    }
    
    if (is.null(citation) & !is.null(title)) {
        output[['query.bibliographic']] <- output$title
        output$title <- NULL
    }
    
    if (!is.null(citation)) {
        output[['query.bibliographic']] <- x[,citation]
        if ('title' %in% names(output)) output$title <- NULL
    }
    
    return(output  %>% bind_cols())   
}
