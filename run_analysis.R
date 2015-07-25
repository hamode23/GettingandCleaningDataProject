## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.


# install and load required R packages
if (!require("data.table")) {
  install.packages("data.table")
  library(data.table)
}

if (!require("reshape2")) {
  install.packages("reshape2")
  library(reshape2)
}

if (!require("plyr")) {
  install.packages("plyr")
  library(plyr)
}

if (!require("dplyr")) {
  install.packages("dplyr")
  library(dplyr)
}

require("data.table")
require("reshape2")
require("plyr")
require("dplyr")


# Load All Files
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")

features <- read.table("./UCI HAR Dataset/features.txt")[,2]

X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# merge data sets
X_full_ds <- rbind(X_test , X_train)
y_full_ds <- rbind(y_test , y_train)
subject_full_ds <- rbind(subject_test , subject_train)

#Extraxt activity labels
activity_labels_names <- activity_labels[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extract_features <- grepl("mean|std", features)

names(X_full_ds) = features

X_full_ds = X_full_ds[,extract_features]

# Load activity labels
y_full_ds[,2] = activity_labels_names[y_full_ds[,1]]
names(y_full_ds) = c("Activity_ID", "Activity_Label")
names(subject_full_ds) = "subject"

# Bind data
full_data <- cbind(subject_full_ds, y_full_ds, X_full_ds)

# Define lables
id_labels   = c("subject", "Activity_ID", "Activity_Label")

# Define only the data labels
data_labels = setdiff(colnames(full_data), id_labels)

# melt data - convert data from wide-format to long-format
melt_data = melt(full_data, id = id_labels, measure.vars = data_labels)

# use dcast to apply mean function to the full dataset
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

# write tidy data to file
write.table(tidy_data, file = "./tidy_data.txt",row.name=FALSE)