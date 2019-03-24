########################################################################################################################
# PARAMETERS
########################################################################################################################

param
(
    [Parameter(Mandatory=$true)]
    $Path,
    [Parameter(Mandatory=$false)]
    $File,
    [Parameter(Mandatory=$false)]
    $FileExceptions,
    [Parameter(Mandatory=$false)]
    $DetailedFiles
)

########################################################################################################################
# FUNCTIONS
########################################################################################################################

function ValidateFileArgument
{
    param
    (
        [Parameter(Mandatory=$true)]
        $File
    )

    # Validate File parameter (directory exist)

    try
    {
        $FilePath = $File.Substring(0,$File.Length - $File.Split("\")[$File.Split("\").Count-1].Length-1)
    }
    catch
    {
        Write-Host "Invalid file path {$File}, please write the full path, for example [C:\Folder\File.txt]"
        return $false
    }
    
    # Validate File parameter(is txt file and doesn't exist)

    if($File.Substring($File.Length-4, 4) -notlike ".txt")
    {
        Write-Host "Invalid file path, it must be a valid .txt file"
        return $false
    }
    elseif(Test-Path($File))
    {
        Write-Host "Invalid file path, the file {$File} already exist"
        return $false
    }
    elseif(-not(Test-Path($FilePath)))
    {
        Write-Host "Invalid file path, the directory {$FilePath} doesn't exist"
        return $false
    }
    else
    {
        return $true
    }
}

function Get-FilesByTypeSummary
{
   param
   (
       [Parameter(Mandatory=$true)]
       $Path
   )

   Write-Host "Retrieving Files By Type Summary..."
   
   $Data = Get-ChildItem -Path $Path -Recurse | Where-Object { !$_.PSIsContainer } |Group-Object Extension | Select-Object @{n="Extension";e={$_.Name -replace '^\.'}}, @{n="Size (MB)";e={[math]::Round((($_.Group | Measure-Object Length -Sum).Sum / 1MB), 2)}}, Count  
   return $Data          
}

function Get-FilesByType
{
    param
    (
       [Parameter(Mandatory=$true)]
       $Path,
       [Parameter(Mandatory=$true)]
       $FileExceptions="cs,xml,txt,cxq"
    )

    Write-Host "Retrieving Files By Type Details..."

    $FilesByExtension = Get-ChildItem -Path $Path -Recurse | Where-Object { !$_.PSIsContainer } | Group-Object Extension
    
    $Exceptions = @()
    foreach($Exception in $FileExceptions.Split(",")){$Exceptions += ".$Exception"}
    
    $TempFile = $File.Substring(0,$File.Length-4)+"_temp.txt"

    foreach($FileType in $FilesByExtension)
    {
      if($FileType.Name -notin $Exceptions)
      {
        Add-Content $TempFile  $FileType.Name 
        Add-Content $TempFile  "------------------------------------------------------"  
        
        foreach($Filename in $FileType.Group)
        {
          Add-Content $TempFile $Filename
        }

        Add-Content $TempFile ""
      }
    }

    $Data = Get-Content $TempFile 
    Remove-Item $TempFile
     
    return $Data
}

function Create-SummaryFile
{
   param
   (
       [Parameter(Mandatory=$true)]
       $File,
       [Parameter(Mandatory=$true)]
       $Data
   )

   # Create temp file with the results

   $TempFile = $File.Substring(0,$File.Length-4)+"_temp.txt"
   Write-Output $Data[0] > $TempFile
   Write-Output "" >> $TempFile
   Write-Output "******************************************************" >> $TempFile
   Write-Output "* FILE NAME BY FILE EXTENSION TYPE" >> $TempFile
   Write-Output "******************************************************" >> $TempFile
   Write-Output "" >> $TempFile
   Write-Output $Data[1] >> $TempFile
   Write-Output "" >> $TempFile
   Write-Output "******************************************************" >> $TempFile
   Write-Output "* FULL PATH BY FILE EXTENSION TYPE" >> $TempFile
   Write-Output "******************************************************" >> $TempFile
   Write-Output "" >> $TempFile
   Write-Output $Data[2] >> $TempFile


   #Create the report

   Write-Host "Creating the report..."
   $TempFileContent = Get-Content $TempFile

   Add-Content $File "======================================================"
   Add-Content $File "    _____                              by Leon Jalfon "
   Add-Content $File "   / ___/__  ______ ___  ____ ___  ____ ________  __  "
   Add-Content $File "   \__ \/ / / / __ '__ \/ __ '__ \/ __ '/ ___/ / / /  "
   Add-Content $File "  ___/ / /_/ / / / / / / / / / / / /_/ / /  / /_/ /   "
   Add-Content $File " /____/\__._/_/ /_/ /_/_/ /_/ /_/\__,_/_/   \__, /    "
   Add-Content $File "                                           /____/     " 
   Add-Content $File "======================================================"
   Add-Content $File ""

   $dateLine = "Date: " + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss tt')

   Add-Content $File $dateLine
   Add-Content $File "File: $Path"
   Add-Content $File ""


   # Add contents from temp file and remove it

   Get-Content $TempFile | Add-Content $File
   Remove-Item -Path $TempFile -Force

   # Finish

   Add-Content $File "=========================================================================="
   Write-Host "Results are available in {$File}"
}

function Get-SpecifiedFilePaths
{
    param
    (
       [Parameter(Mandatory=$true)]
       $Path,
       [Parameter(Mandatory=$true)]
       $SearchFiles="dll,png"
    )

    Write-Host "Retrieving Specified Files Paths..."

    $FilesPathByExtension = Get-ChildItem -Path $Path -Recurse | Where-Object { !$_.PSIsContainer } | select FullName, Extension
    
    $FilesToSearch = @()
    foreach($FileToSearch in $SearchFiles.Split(",")){$FilesToSearch += ".$FileToSearch"}
    
    $TempFile = $File.Substring(0,$File.Length-4)+"_temp.txt"

    foreach($Extension in $FilesToSearch)
    {
      Add-Content $TempFile  $Extension
      Add-Content $TempFile  "------------------------------------------------------"

      $FilesByFullName = $FilesPathByExtension | Where-Object {$_.Extension -eq "$Extension"} | Select FullName
      foreach($FilePath in $FilesByFullName.FullName){Add-Content $TempFile $FilePath}
      
      Add-Content $TempFile ""
    }

    $Data = Get-Content $TempFile 
    Remove-Item $TempFile
     
    return $Data
}

########################################################################################################################
# RUN SCRIPT
########################################################################################################################

try
{
    $FilesByTypeSummary = Get-FilesByTypeSummary -Path $Path
    $FilesByType = Get-FilesByType -Path $Path -FileExceptions $FileExceptions

    if($DetailedFiles)
    {
       $FilesPathsByType = Get-SpecifiedFilePaths -Path $Path -SearchFiles $DetailedFiles
    }
    
    if($File -and (ValidateFileArgument -File $File))
    {
        Create-SummaryFile -File $File -Data $FilesByTypeSummary,$FilesByType,$FilesPathsByType 
    }
    else
    {
        Write-Host $FilesByTypeSummary
        Write-Host ""
        Write-Host $FilesByType
        Write-Host ""
        Write-Host $FilesPathsByType
    }
}
catch
{
    Write-Host "Error, Exception: $_"
}

########################################################################################################################
