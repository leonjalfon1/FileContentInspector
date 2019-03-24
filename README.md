# FileContentInspector
Powershell script to retrieve and summarize the file content of an specific directory

---

## Example Uses

 - Find how many files of each extension do you have
 - Find which types of files there are in an specific folder
 - Find the total space occupied by a file type

---
 
## Requisites

 - Powershell version 2.0 or later
 
---
 
## Parameters

### Mandatory

#### Path
 - Directory to be analized
 - Example: "C:\Users\user\Desktop\File"

### Optional

#### File
 - Full path of the summary file to create with the results
 - Example: "C:\Users\user\Desktop\SummaryFile.txt"
 - Note: If File is not specified the result will be shown in the console
 
---

## Usage

- Mandatory
```
.\FileContentInspector.ps1 -Path "C:\Users\user\Desktop\File"
```
- All
```
.\FileContentInspector.ps1 -Path "C:\Users\user\Desktop\File" -File "C:\Users\user\Desktop\SummaryFile.txt" -FileExceptions "cs,txt,config" -DetailedFiles "dll,png,jpg"
```
 
---
 
## Summary Report

 - Show all the files types stored in the specified path
 - Show the total files of each type in the specified path (count and total)
 
---

## Contributing

 - Please feel free to contribute, suggest ideas or open issues
