# Step 0
# Prepare: download, unzip
################################################################################

# Clean up workspace
rm(list=ls())

## Create temp directory for result
result_dir = "./result"
if(!dir.exists(result_dir)) {
    dir.create(result_dir)
}

## Create temp directory for data
data_dir = "./data"
if(!dir.exists(data_dir)) {
    dir.create(data_dir)
}

## Download file
archive_file <- file.path(data_dir, "UCI HAR Dataset.zip")
if(!file.exists(archive_file)) {
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(url, archive_file)
}

## Unpack archive
if(!dir.exists(file.path(data_dir, "UCI HAR Dataset"))) {
    unzip(archive_file, exdir = data_dir)
}

# Set working directory to the location where the UCI HAR Dataset was unzipped
old_wd <- getwd()
setwd(file.path(data_dir, "UCI HAR Dataset"))


# Step 1
# Merge the training and test sets to create one data set
################################################################################

subject_train <- read.table("./train/subject_train.txt", header = FALSE)
X_train <- read.table("./train/X_train.txt", header = FALSE)
y_train <- read.table("./train/y_train.txt", header = FALSE)

subject_test <- read.table("./test/subject_test.txt", header = FALSE)
X_test <- read.table("./test/X_test.txt", header = FALSE)
y_test <- read.table("./test/y_test.txt", header = FALSE)


# create data set: train + test
X_data <- rbind(X_train, X_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

# Step 2
# Extract only the measurements on the mean and standard deviation 
# for each measurement
################################################################################


features <- read.table("features.txt")

# only columns with mean() or std()
mean_and_std_features <- grep("-(mean|std)\\(\\)", features[, 2])
X_data <- X_data[, mean_and_std_features]
names(X_data) <- features[mean_and_std_features, 2]


# Step 3
# Use descriptive activity names to name the activities in the data set
###############################################################################

activities <- read.table("activity_labels.txt")

# update values with correct activity names
y_data[, 1] <- activities[y_data[, 1], 2]
names(y_data) <- "activity"


# Step 4
# Appropriately label the data set with descriptive variable names
###############################################################################

# correct column name
names(subject_data) <- "subject"

# bind all the data in a single data set
data <- cbind(X_data, y_data, subject_data)

names(data) <- gsub("\\()", "", names(data))
names(data) <- gsub("-std", "StdDev", names(data))
names(data) <- gsub("-mean", "Mean", names(data))
names(data) <- gsub("^t", "time", names(data))
names(data) <- gsub("^f", "frequency", names(data))
names(data) <- gsub("Acc", "Accelerometer", names(data))
names(data) <- gsub("Gyro", "Gyroscope", names(data))
names(data) <- gsub("Mag", "Magnitude", names(data))
names(data) <- gsub("BodyBody", "Body", names(data))


# Step 5
# Create a second, independent tidy data set with the average of each variable
# for each activity and each subject
###############################################################################

library(plyr)
# 66 <- 68 columns but last two (activity & subject)
averages_data <- ddply(data, .(subject, activity), function(x) colMeans(x[, 1:66]))

setwd(old_wd)
write.table(averages_data, file.path(result_dir, "tidy.txt"), row.name = FALSE)