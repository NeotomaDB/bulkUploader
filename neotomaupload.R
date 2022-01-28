## ----setup, results='hide', message=FALSE----------------------------------------------------------------------------------------------
#how will uploading these things work for meaghan? will she need to install r tools?
#need to install r tools and hit the build button
library(bulkUploader)
devtools::install_github('NeotomaDB/neotoma2')
library(neotoma2)
library(purrr)
library(dplyr)
library(httr)

#Set your working directory to be the neotoma citations folder.


## ----scrapedois, results='hide'--------------------------------------------------------------------------------------------------------

# Note that `miomapcsv` is a data element contained within the `bulkUploader` package, however the `neotoma_pubs` object is not.

neotoma <- readr::read_csv('neotoma_pubs.csv')


#Ideally this code would be massaged.  The issue here is that there is title and journal information in several places.  It's not the nicest way of doing things.

pubList <- formatPubs(neotoma,
                      citation = 'citation',
                      year = 'year',
                      title = c('articletitle', 'booktitle'),
                      doi = 'doi')
colnames(pubList)[3] <- "query.bibliographic"

#restore=TRUE will load the previous results if you stop the function mid way.
#this loads the new scrape_dois function
source('scrape_dois.r')

outputs <- scrape_dois(pubList,
            n = 3,
            savefile = 'neotomatab.RDS',
            restore = TRUE)

dat <- readRDS("neotomatab.RDS")
dat2 <- readRDS("neotomatabfull.RDS")
#seems to not work throws an error  Error: $ operator is invalid for atomic vectors
#not sure what my new code does to make this happen
#results <- map(outputs, get_cr_results)
results <- map(dat, get_cr_results)

results2 <- map(dat2, get_cr_results)
for (i in 1:length(dat2)) {
  aa <- get_cr_results(dat2[[i]])

}

## ----reviewPubs------------------------------------------------------------------------------------------------------------------------
#From this output we have a `list` object called `outputs`, with a length equal to the number of publications in the original data file.  We have a `list` called `results` with a length equal to the length of `outputs`.  The `results` object is made up of individual `data.frame`s, with columns `score` and `delta`, showing the quality of each match returned by the CrossRef API, and the quality of subsequent matches (using the CrossRef scoring value).  Knowing the `delta` is useful to understand the quality of the matches.  High quality matches have a high `delta` score between the first and second matches, and a generally high `score` value.

#The `score` gives the approximate match strength to a publication in CrossRef.  The `delta` lets us know what the score of the next closest match is.  Because we need to work with the CrossRef API in a reasonable way, this matching tends to be slow.

#Once this script runs we then have a set of publications for the constituent database, and for each described publication we have 0 or more potential matches.  To generate a simple match we want to create some form of citation.  We can do this using the very simple helper function `makeCite()`.

neoCites <- makeCite(pubList$query.bibliographic)

crossCites <- outputs %>% map(cr_to_neotoma)

#Now, for each publication we have a set of possible matches, and scores.  We need to prompt the user to select the best match:
#The `matchPubs()` function goes through each of the publications and provides the user with the ability to select the best match for a publication (if it exists) based on the CrossRef metadata.
## ----getMatches, results='hide'--------------------------------------------------------------------------------------------------------
#Can saving the RDS object like we did for scrape_dois works here? no needs to be coded to save
source('matchPubs.r')

bestMatch <- matchPubs(cross = crossCites,
                       pubs = neoCites,
                       results = results,
                       savefile= "matchedneotomatest.RDS",
                       restore = TRUE)

matcheddat <- readRDS("matchedneotoma.RDS")

#best match saved the information into a RDS file





