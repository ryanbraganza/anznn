---
layout: post
category: Batch Upload
title: Batch Upload
group: manual
---
## Batch upload file format
Batch uploads must be provided as a CSV file. The CSV file should contain a header row and one row for each baby records. You must include a column "BabyCODE" which contains a unique code for each record. The other column headers should match the data item codes from the ANZNN data dictionary.

* Dates should be provided in yyyy-mm-dd or dd/mm/yyyy format.
* Times should be provided in hh:mm format (24 hour time). 00:00 is the start of the day.

## Starting a new batch upload
Click on the 'Batch Uploads' tab from the home page. 

Select the registration type and year of registration, then browse for the file you wish to upload. Depending on which registration type you chose, you may also be given the option to upload supplementary files. These are optional and can be selected if you wish to supply some of the data in separate tables. If you wish to supply all your data in a single file you can ignore these additional file selection options.

Once you have selected your file(s), click the 'Upload' button. You will be returned to the batch uploads list screen and will see your file in the list. Initially it will have a status of 'In Progress'. 

![New batch upload](/user_manual/assets/images/batch/upload.png)
*Fig 1. New batch upload*

It may take some time for the system to process your file depending on the file size and current load on the system. You can click the 'Refresh Status' button to check if processing is complete, or can come back later to check.

![In progress](/user_manual/assets/images/batch/progress.png)
*Fig 2. batch upload in progress*

## Reviewing the outcome
Once the system has finished processing your file, the status will change. The status will be one of:
* **Failed** - there was one or more problems with the file and it has not been accepted. The "Details" column will contain additional information to help you find the problems. Depending on what type of problems were found, you may also be able to download a 'Detail' and 'Summary' report which will give you a full breakdown of the problems in the file. Once you have corrected the problems you can re-upload your file.
* **Processed Successfully** - your data has been accepted and no problems were detected. No further action is needed.
* **Needs Review** - your data has one or more warnings - you should review the warnings in the summary and detail reports, and if you are sure the data is correct, a user with "Supervisor" access can submit the file. If the data is not correct, you can re-upload the file with the problems corrected.

![Status and reports](/user_manual/assets/images/batch/outcome.png)
*Fig 3. Viewing status and reports*

## Viewing reports
Depending on the outcome of your upload, a summary and/or detail report may be generated. You can access these by clicking the links in the last column of the list. The summary report is in PDF format suitable for printing. The detail report is in CSV format and can be opened with Microsoft Excel or similar software. The reports provide a full breakdown of the validation errors for your file.

## Submitting files with warnings
If your file has a status of 'Needs Review', and you have checked to confirm that the data is correct, it can be submitted by a user with 'Supervisor' level access. If you do not have 'Supervisor' access, you will need to ask a supervisor to submit for you. If you are a 'Supervisor', you can submit the file by clicking the 'Force Submit' button for the file you wish to submit. It will then take a few minutes to be processed.

![Submitting](/user_manual/assets/images/batch/force.png)
*Fig 3. Submitting a file with warnings*

