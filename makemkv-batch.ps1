# Specify the location of the makeMkvCon64.exe executable
$exeLoc = "C:\Program Files (x86)\MakeMKV\makeMkvCon64.exe"

# Prompt the user to enter the path containing DVD folders or ISO files
$dvdPath = Read-Host "Enter the path to the DVD folders or ISO files"

# Initialize variables for progress tracking and logging
$currentFolder = 0
$totalFolders = 0
$logFolderPath = Join-Path $dvdPath "Logs"
$logFilePath = Join-Path $logFolderPath "WholeProcessLog.txt"
$successCount = 0
$failureCount = 0

# Create the log folder if it doesn't exist
if (-not (Test-Path $logFolderPath -PathType Container)) {
    New-Item -Path $logFolderPath -ItemType Directory | Out-Null
}

# Count the total number of VIDEO_TS folders and ISO files
function Count-DVDItems {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$path
    )

    Get-ChildItem -Path $path -Recurse -Directory | ForEach-Object {
        if (Test-Path -Path "$($_.FullName)\VIDEO_TS" -PathType Container) {
            $global:totalFolders++
        }
    }

    Get-ChildItem -Path $path -Filter "*.iso" -File -Recurse | ForEach-Object {
        $global:totalFolders++
    }
}

# Process VIDEO_TS folders using makeMkvCon64.exe
function Process-VideoTS {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$path
    )

    # Loop through all subdirectories
    Get-ChildItem -Path $path -Directory | ForEach-Object {
        # Check if the current directory is a VIDEO_TS folder
        if (Test-Path -Path "$($_.FullName)\VIDEO_TS" -PathType Container) {
            $videoTSDir = "$($_.FullName)\VIDEO_TS"
            $parentDir = Split-Path -Path $videoTSDir -Parent

            # Process the VIDEO_TS folder using makeMkvCon64.exe
            Write-Host "Processing VIDEO_TS folder: $videoTSDir"

            # Update the current progress
            $global:currentFolder++
            Write-Progress -Activity "Processing DVD folders" -Status "Progress" -PercentComplete (($currentFolder / $totalFolders) * 100)

            # Create a log file for the current DVD
            $dvdLogFilePath = Join-Path $logFolderPath "$($_.Name)_Log.txt"
            $logContent = "Log for DVD: $videoTSDir`n`n"
            $logContent | Out-File -FilePath $dvdLogFilePath -Append

            # Redirect the makeMkvCon64.exe output to the log file
            & $exeLoc mkv "$videoTSDir" 0 "$parentDir" 2>&1 | Out-File -FilePath $dvdLogFilePath -Append

            Write-Host "Completed processing VIDEO_TS folder: $videoTSDir"

            # Append the DVD log to the whole process log
            $logContent = "`n`nDVD: $videoTSDir`n"
            $logContent += Get-Content -Path $dvdLogFilePath
            $logContent | Out-File -FilePath $logFilePath -Append

            # Increment the success or failure count based on the presence of errors in the log
            if ((Get-Content -Path $dvdLogFilePath) -match "Error") {
                $global:failureCount++
            } else {
                $global:successCount++
            }
        }

        # Recursively call the function for subdirectories
        Process-VideoTS -path $_.FullName
    }
}

# Process ISO files using makeMkvCon64.exe
function Process-ISOFiles {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$path
    )

    # Loop through all ISO files
    Get-ChildItem -Path $path -Filter "*.iso" -File -Recurse | ForEach-Object {
        $isoFilePath = $_.FullName
        $parentDir = Split-Path -Path $isoFilePath -Parent

        # Process the ISO file using makeMkvCon64.exe
        Write-Host "Processing ISO file: $isoFilePath"

        # Update the current progress
        $global:currentFolder++
        Write-Progress -Activity "Processing DVD folders" -Status "Progress" -PercentComplete (($currentFolder / $totalFolders) * 100)

        # Create a log file for the current ISO file
        $isoLogFilePath = Join-Path $logFolderPath "$($_.Name)_Log.txt"
        $logContent = "Log for ISO file: $isoFilePath`n`n"
        $logContent | Out-File -FilePath $isoLogFilePath -Append

        # Redirect the makeMkvCon64.exe output to the log file
        & $exeLoc mkv iso:"$isoFilePath" 0 "$parentDir" 2>&1 | Out-File -FilePath $isoLogFilePath -Append

        Write-Host "Completed processing ISO file: $isoFilePath"

        # Append the ISO file log to the whole process log
        $logContent = "`n`nISO file: $isoFilePath`n"
        $logContent += Get-Content -Path $isoLogFilePath
        $logContent | Out-File -FilePath $logFilePath -Append

        # Increment the success or failure count based on the presence of errors in the log
        if ((Get-Content -Path $isoLogFilePath) -match "Error") {
            $global:failureCount++
        } else {
            $global:successCount++
        }
    }
}

# Call the function to count the total number of VIDEO_TS folders and ISO files
Count-DVDItems -path $dvdPath

# Call the function to process VIDEO_TS folders
Process-VideoTS -path $dvdPath

# Call the function to process ISO files
Process-ISOFiles -path $dvdPath

# Display completion message with success and failure counts
Write-Host "`n------------------------"
Write-Host "`nRemux process completed."
Write-Host "`n------------------------"
Write-Host "Total successful remuxes:" -ForegroundColor Green
Write-Host "`t$successCount" -ForegroundColor Green 
Write-Host "Total failed remuxes:" -ForegroundColor Red
Write-Host "`t$failureCount" -ForegroundColor Red
Write-Host "More information is available in the Logs folder located at:" -ForegroundColor Yellow
Write-Host "`t$logFolderPath" -ForegroundColor Yellow
Write-Host "`n------------------------"
