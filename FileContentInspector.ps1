########################################################################################################################
# PARAMETERS
########################################################################################################################

param
(
    [Parameter(Mandatory=$true)]
    $Path,
    [Parameter(Mandatory=$false)]
    $File
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

########################################################################################################################
# RUN SCRIPT
########################################################################################################################

try
{
    if($File)
    {
        if(ValidateFileArgument -File $File) 
        {
            # Group by extension (count + total)

            Write-Host "Inspecting the specified path..."
            $Data = Get-ChildItem -Path $Path -Recurse |Where-Object { !$_.PSIsContainer } |Group-Object Extension |Select-Object @{n="Extension";e={$_.Name -replace '^\.'}}, @{n="Size (MB)";e={[math]::Round((($_.Group | Measure-Object Length -Sum).Sum / 1MB), 2)}}, Count
            

            # Create temp file with the results

            $TempFile = $File.Substring(0,$File.Length-4)+"_temp.txt"
            Write-Output $Data > $TempFile


            #Create the report

            Write-Host "Creating the report..."
            $TempFileContent = Get-Content $TempFile

            Add-Content $File "=========================================================================="
            Add-Content $File "                                                           by Leon Jalfon "
            Add-Content $File "      _______ __        _____                                             "
            Add-Content $File "     / ____(_) /__     / ___/__  ______ ___  ____ ___  ____ ________  __  "
            Add-Content $File "    / /_  / / / _ \    \__ \/ / / / __ '__ \/ __ '__ \/ __ '/ ___/ / / /  "
            Add-Content $File "   / __/ / / /  __/   ___/ / /_/ / / / / / / / / / / / /_/ / /  / /_/ /   "
            Add-Content $File "  /_/   /_/_/\___/   /____/\__._/_/ /_/ /_/_/ /_/ /_/\__,_/_/   \__, /    "
            Add-Content $File "                                                               /____/     " 
            Add-Content $File "=========================================================================="
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
    }
    else
    {
        # Group by extension (count + total)
        Get-ChildItem -Path $Path -Recurse |Where-Object { !$_.PSIsContainer } |Group-Object Extension |Select-Object @{n="Extension";e={$_.Name -replace '^\.'}}, @{n="Size (MB)";e={[math]::Round((($_.Group | Measure-Object Length -Sum).Sum / 1MB), 2)}}, Count
    }
}
catch
{
    Write-Host "Error, Exception: $_.Exception.Message"
}

########################################################################################################################
