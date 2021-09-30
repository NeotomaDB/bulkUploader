#' @export
credential <- setClass("credential",
    representation(username="character",
                   password="character",
                   valid="logical"))

#' @export
setMethod("show", 
    signature = "credential",
    definition = function(object) {
        cat("User credentials:\n")
        cat("User name: ", object@username, "\n")
        cat("Password:   ***************\n")
        if(is.na(object@valid)) {
            cat("User credentials have not been validated.\n")
        } else if (object@valid) {
            cat("User credentials are valid for:\n")
            print(attr(object@valid, 'dbs'))
        } else {
            cat("Invalid credentials.\n")
        }
    }
)

#' @export
addCredentials <- function(username, password) {
    new("credential", username = username, password = password, valid=NA)
}

#' @export 
checkCredentials <- function(credentials) {
    mod <- credentials

    test <- httr::GET(url="https://tilia.neotomadb.org/api/",
                      query = list(method="ts.validatesteward",
                                   `_username`=URLencode(paste0("'",credentials@username,"'")),
                                   `_pwd`=URLencode(paste0("'",credentials@password, "'"))))
    if(!status_code(test) == 200) {
        stop('No valid response from the Neotoma Server.\nCheck your username and password, and check the server status at http://data.neotomadb.org')
    } else {
        
        dbs <- sapply(content(test)$data, '[[', 'databaseid')

        if (length(dbs) > 0) {
            mod@valid = TRUE
            constdb <- neotoma2::get_table('constituentdatabases', limit = 999)
            attr(mod@valid, 'dbs') <- data.frame(dbid = dbs,
                                                 databasename = constdb$databasename[match(dbs, constdb$databaseid)])
        } else {
            mod@valid = FALSE
            warning("The provided credentials are not recognized in the Neotoma Database.")
        }
    }
    return(mod)
}
