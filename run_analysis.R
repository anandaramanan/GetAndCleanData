PrepareTidyHARDataSet <- function() {
  
  # The basic set up - load the packages and set the path
    
    require("knitr")
    require("markdown")
    require("data.table")
    require("reshape2")
    require("sqldf")
    path <- getwd()
  
  # Get the data - download, unzip, load to data tables
    
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    file <- "Dataset.zip"
    if (!file.exists(path)) {dir.create(path)}
    download.file(url, file.path(path, file), method="curl")
    unzip("./Dataset.zip", overwrite=TRUE, unzip = "internal")
  
    InputPath <- file.path(path, "UCI HAR Dataset")
    dtSubjectTraining <- data.table(read.table(file.path(InputPath, "train", "subject_train.txt")))
    dtSubjectTest <- data.table(read.table(file.path(InputPath, "test", "subject_test.txt")))
    dtActivityTraining <- data.table(read.table(file.path(InputPath, "train", "y_train.txt")))
    dtActivityTest <- data.table(read.table(file.path(InputPath, "test", "y_test.txt")))
    dtReadingTraining <- data.table(read.table(file.path(InputPath, "train", "X_train.txt")))
    dtReadingTest <- data.table(read.table(file.path(InputPath, "test", "X_test.txt")))
  
  # Merge the training and the test data sets (rows) and subject, activity and reading data (columns)
    
    dtSubject <- rbind(dtSubjectTraining, dtSubjectTest)
    setnames(dtSubject, "V1", "subject")
    dtActivity <- rbind(dtActivityTraining, dtActivityTest)
    setnames(dtActivity, "V1", "activityNum")
    dtReading <- rbind(dtReadingTraining, dtReadingTest)
    dt <- cbind(dtSubject, dtActivity, dtReading)
    setkey(dt, subject, activityNum)
  
  # Extract only the mean and the standard deviation columns from this merged data table:
  
    dfFeatures <- read.table(file.path(InputPath, "features.txt"),stringsAsFactors=FALSE)
    setnames(dfFeatures, names(dfFeatures), c("featureNumber", "featureName"))
    toMatch <- c("mean\\(\\)","std\\(\\)")
    dfFeatures <- dfFeatures[grep(paste(toMatch,collapse="|"), dfFeatures$featureName, value=FALSE),]
    
    NewColumnNames <- c("featureCode", "DomainSignalType", "AccelerationSignalType", "SignalSource", "JerkSignalMeasure",
                        "SignalMagnitudeMeasure","EstimatedVariable","SignalAxis")
    dfFeatures[,NewColumnNames] <- sqldf("SELECT 
    ('V'||featureNumber) as featureCode,
    (CASE WHEN FeatureName like 't%' THEN 'Time' 
          WHEN FeatureName like 'f%' THEN 'Frequency' END) as DomainSignalType,
    (CASE WHEN FeatureName like '%BodyAcc%' THEN 'Body' 
          WHEN FeatureName like '%GravityAcc%' THEN 'Gravity' ELSE 'NA' END) as AccelerationSignalType,
    (CASE WHEN FeatureName like '%Acc%' THEN 'Accelerator' 
          WHEN FeatureName like '%Gyro%' THEN 'Gyroscope' END) as SignalSource,
    (CASE WHEN FeatureName like '%Jerk%' THEN 'Yes' ELSE 'No' END) as JerkSignalMeasure,
    (CASE WHEN FeatureName like '%Mag%' THEN 'Yes' ELSE 'No' END) as SignalMagnitudeMeasure,
    (CASE WHEN FeatureName like '%mean%' THEN 'Mean' 
          WHEN FeatureName like '%std%' THEN 'StdDev' END) as EstimatedVariable,
    (CASE WHEN FeatureName like '%-X%' THEN 'X' 
          WHEN FeatureName like '%-Y%' THEN 'Y'
          WHEN FeatureName like '%-Z%' THEN 'Z'
          ELSE 'NA' END) as SignalAxis
          FROM dfFeatures")
    dtFeatures <- data.table(dfFeatures)
  
  # Add activity name from the activity label to the merged data table and add to its key
  
    neededcolumns <- c(key(dt), dtFeatures$featureCode)
    dt <- dt[,neededcolumns,with=FALSE]
    dtActivityNames <- data.table(read.table(file.path(InputPath, "activity_labels.txt")))
    setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))
    dt <- merge(dt, dtActivityNames, by="activityNum", all.x=TRUE)
    setkey(dt, subject, activityNum, activityName)
  
  # Melt the data table to reshape it - normalize it by converting readings for variables from col to rows - to add the feature name.
    dt <- data.table(melt(dt, key(dt), variable.name="featureCode"))
    dtSubset <- merge(dt, dtFeatures[, ], by="featureCode", all.x=TRUE)
  
  # Create tidy data sets with the average of each variable for each activity and each subject - in wide and long formats.
    setkey(dtSubset, subject, activityName, featureName)
    dtTidyLong <- dtSubset[, list(average = mean(value)), by=key(dtSubset)]
    
    setkey(dtSubset, subject, activityName, DomainSignalType, AccelerationSignalType, SignalSource, JerkSignalMeasure,SignalMagnitudeMeasure, EstimatedVariable, SignalAxis)
    dtTidierLong <- dtSubset[, list(average = mean(value)), by=key(dtSubset)]
  
    dtTidyWide <- dcast(dtTidyLong, subject+activityName~featureName, value.var="average")
  
  # Finally write to text files as needed
    write.table(dtTidyWide, file.path(path, "HumanActivityRecognition_Using_Smartphones_WideTidy.txt"), quote = FALSE, sep = "\t", row.names = FALSE)
    write.table(dtTidyLong, file.path(path, "HumanActivityRecognition_Using_Smartphones_LongTidy.txt"), quote = FALSE, sep = "\t", row.names = FALSE)
    write.table(dtTidierLong, file.path(path, "HumanActivityRecognition_Using_Smartphones_LongTidier.txt"), quote = FALSE, sep = "\t", row.names = FALSE)
}