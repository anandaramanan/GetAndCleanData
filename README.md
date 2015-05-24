# Project requirements:
One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 

A full description is available at the site where the data was obtained: 
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The data for the project:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

**Create a `run_analysis.R` script that does the following:**

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Steps to reproduce this project:
1. Save the R script `run-analysis.R` in your working folder
2. Read the R code from this file by entering `source(“run_analysis.R”)`
3. Call the function `PrepareTidyHARDataSet()`
This will download the data files and do the necessary processing.

# Outputs produced:
After running the above function the below three tidy dataset files will be created in the working folder:

1. HumanActivityRecognition_Using_Smartphones_WideTidy.txt :  
`This is the text file uploaded as part of the project submission.` The data in this is in the wide form with all the mean and standard deviation feature variables as separate columns.
2. HumanActivityRecognition_Using_Smartphones_LongTidy.txt :  
The data in this is in the long form with the names and values of the mean and standard deviation feature variables as new columns.
3. HumanActivityRecognition_Using_Smartphones_LongTidier.txt :  
The data in this is in also in the long form but a bit more tidy`. Here the composite-variable column featurename is further split into seven separate columns making it even more tidy and easy to understand.

# Additional information:
* The `Codebook.md` describes the variables, the data, and the transformations/work performed to clean up the data.
* Please use the `read.table` function to read the tidy data set text file for better clarity and checking.