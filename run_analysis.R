# if dataset is not download, get it from the course website

setwd("/Users/augusto/data/data-assig")

if(!dir.exists("UCI HAR Dataset")) {
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip ", destfile = "dataset.zip", method = "curl")
  unzip("dataset.zip")
}

