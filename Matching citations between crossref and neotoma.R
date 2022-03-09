#This code is for matching the neotoma citations with citations found in Crossref

#In order to use the bulkUploader package you will need to install r tools. Under the build tab in the environment you can hit the Install and Restart button. Also make sure that the bulkUploader project is loaded.

library(bulkUploader)
devtools::install_github('NeotomaDB/neotoma2')
library(neotoma2)
library(purrr)
library(dplyr)
library(httr)


#reading in the neotoma citations
neotoma <- readr::read_csv('./data/neotoma_pubs.csv')

pubList <- formatPubs(neotoma,
                      citation = 'citation',
                      year = 'year',
                      title = c('articletitle', 'booktitle'),
                      doi = 'doi')

#reading in the references from Crossref
outputs <- readRDS('./data/neotomatabfull.RDS')

results <- map(outputs, get_cr_results)


#From this output we have a `list` object called `outputs`, with a length equal to the number of publications in the original data file.  We have a `list` called `results` with a length equal to the length of `outputs`.  The `results` object is made up of individual `data.frame`s, with columns `score` and `delta`, showing the quality of each match returned by the CrossRef API, and the quality of subsequent matches (using the CrossRef scoring value).  Knowing the `delta` is useful to understand the quality of the matches.  High quality matches have a high `delta` score between the first and second matches, and a generally high `score` value.

#The `score` gives the approximate match strength to a publication in CrossRef.  The `delta` lets us know what the score of the next closest match is.  Because we need to work with the CrossRef API in a reasonable way, this matching tends to be slow.

#Once this script runs we then have a set of publications for the constituent database, and for each described publication we have 0 or more potential matches.  To generate a simple match we want to create some form of citation.  We can do this using the very simple helper function `makeCite()`.

neoCites <- makeCite(pubList$citation)

crossCites <- outputs %>% map(cr_to_neotoma)

#Now, for each publication we have a set of possible matches, and scores.  We need to select the best match for each citation. The `matchPubs()` function goes through each of the publications and provides the user with the ability to select the best match for a publication (if it exists) based on the CrossRef metadata.

#by having restore = TRUE the matches you make will be saved in a RDS file. This way you can save your progress and reload the file by running the command again. This allows you to pick up where you left off.
bestMatch <- matchPubs(cross = crossCites,
                       pubs = neoCites,
                       results = results,
                       savefile = 'data/matchedneotomafull.RDS',
                       restore = TRUE)

