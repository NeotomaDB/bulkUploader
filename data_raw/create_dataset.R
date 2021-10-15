# create pavela data file

files <- list.files(path = "data_raw/pavela", full.names = TRUE)
names <- gsub("data_raw/pavela/", "", files)
names <- gsub(".txt", "", names)

# read in files and merge into a list
dat<- list()

for (i in 1:length(files)){
  temp <- read.delim(files[i], header=T, sep="\t", fileEncoding="UTF-8")
  assign(names[i], temp)
  dat[[i]] <- get(names[i])
}

names(dat) <- names

pavela <- dat
usethis::use_data(pavela)
