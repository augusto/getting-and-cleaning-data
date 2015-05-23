# if dataset is not download, get it from the course website
library(dplyr)
library(reshape2)

# set workspace
setwd("/Users/augusto/data/data-assig")
rm(list=ls())


# Download dataset (if required)
if(!dir.exists("UCI HAR Dataset")) {
  if( !file.exists("getdata_projectfiles_UCI HAR Dataset.zip")) {
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip ", destfile = "getdata_projectfiles_UCI HAR Dataset.zip", method = "curl")
  }
  unzip("getdata_projectfiles_UCI HAR Dataset.zip")
}

# load activity labels
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE, col.names=c("activityid","activitylabel"))

# load feature labels
featureLabels <- read.csv("UCI HAR Dataset/features.txt", sep = " ", header = FALSE, col.names=c("featureid","featurelabel"))

# load and merge feature data
testFeatures <- read.table("UCI HAR Dataset/test/X_test.txt", colClasses="numeric", col.names=featureLabels$featurelabel)
trainFeatures <- read.table("UCI HAR Dataset/train/X_train.txt", colClasses="numeric", col.names=featureLabels$featurelabel)
features <- rbind(testFeatures, trainFeatures)
remove(testFeatures, trainFeatures)

# load and merge activity data
testActivity <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE, colClasses="integer", col.names="activityid")
trainActivity <- read.csv("UCI HAR Dataset/train/y_train.txt", header = FALSE, colClasses="integer", col.names="activityid")
activity <- rbind(testActivity, trainActivity)
remove(testActivity, trainActivity)

# load and merge subject data
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE, colClasses="integer", col.names="subjectid")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE, colClasses="integer", col.names="subjectid")
subject <- rbind(testSubjects, trainSubjects)
remove(testSubjects, trainSubjects)

# select which metrics to keep (only mean and std)
meanFeaturesIndices <- grep("mean\\(\\)", featureLabels$featurelabel)
stdFeaturesIndices <- grep("std\\(\\)", featureLabels$featurelabel)
featuresToKeep <- cbind(meanFeaturesIndices, stdFeaturesIndices)
remove( meanFeaturesIndices, stdFeaturesIndices)

selectedFeatures <- features[,featuresToKeep]

# transform names to be more human readable
cleanNames <- tolower(gsub("[\\(\\),\\-]","",featureLabels$featurelabel[featuresToKeep]))
cleanNames <- gsub("^t","time",cleanNames)
cleanNames <- gsub("^f","fourier",cleanNames)
names(selectedFeatures) <- cleanNames
remove(cleanNames)

# put all data into one dataframe in preparation to melt it.
subjectActivity <- cbind(subject, activity)
allData <- cbind(selectedFeatures, subjectid=subjectActivity$subjectid, activityid=subjectActivity$activityid)


meltedData <- melt(allData, id.vars = c("subjectid","activityid"))
meanPerSubjectAndActivity <- dcast(meltedData, subjectid + activityid ~ variable, fun.aggregate=mean)

remove(subjectActivity, allData, meltedData)
write.table(meanPerSubjectAndActivity, "tidy.txt", row.names = F);
