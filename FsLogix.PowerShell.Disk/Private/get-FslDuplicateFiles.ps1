function get-FslDuplicateFiles {
    [CmdletBinding()]
    <#
        .SYNOPSIS
        Obtains all duplicate files per VHD within each directory.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER Path
        User specified location to a virtual disk

        .PARAMETER FolderPath
        Optional user specificed folder within a virtual disk

        .PARAMETER Csvpath
        User option to either have duplicate data CSV file generated or not.

        .PARAMETER Remove
        User option to delete duplicate files

        .EXAMPLE
        get-FslDuplicateFiles -path C:\Users\Danie\Documents\test\test1.vhd
        Will find all the duplicate files in, test1.vhd, and output them via verbose

        .EXAMPLE
        get-FslDuplicateFiles -path C:\Users\Danie\Documents\test -CsvPath C:\Users\Danie\Documents\test\results.csv
        Will obtain all the virtual disks within the path directory and output the data to a csv file named 'results.csv'

        .EXAMPLE
        get-FslDuplicateFiles -path C:\Users\Danie\Documents\test -CsvPath C:\Users\Danie\Documents\test\results.csv -remove
        Will obtain all the virtual disks within the path directory and output the data to a csv file named 'results.csv'.
        Then the program will delete all the files labled as 'duplicate'.
    #>
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$path,

        [Parameter(Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$Folderpath,

        [Parameter(Position = 2, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$Csvpath,

        [Parameter(Position = 3)]
        [Switch]$Remove
    )

    begin {
        ## Need to find a way to find all redundant files ##
        $opt = (Get-Host).PrivateData
        $opt.WarningBackgroundColor = "DarkRed"
        $opt.WarningForegroundColor = "White"
        set-strictmode -Version latest
    }

    process {
        $name = split-path -path $path -leaf

        if ($Csvpath -ne "" -and $Csvpath -notlike "*.csv") {
            Write-Error "$CSVPath must have a .csv extension" -ErrorAction Stop
        }

        ## Helper functions built in will help with error checking ##
        $DriveLetter = get-Driveletter -path $path
        $Path_To_Search = join-path ($DriveLetter)($folderpath)
        Write-Verbose "$(Get-Date): Searching for Duplicates in $name"

        if (-not(test-path -path $Path_To_Search)) {
            Write-Error "$name : Could not find path: $Path_To_Search" -ErrorAction Stop
        }

        ## Need a better way to do this.                              ##
        ## Trying to store $Path_To_Search and $Directories together. ##
        $dirlist = New-Object System.Collections.Queue
        $dirlist.Enqueue($Path_To_Search) ## Start with the root value

        $Directories = get-childitem -path $Path_To_Search -Recurse | Where-Object { $_.PSIsContainer } -ErrorAction Stop | Select-Object FullName

        foreach ($dir in $Directories) {
            ## Add each directory
            $dirlist.Enqueue($dir.FullName)
        }

        <# 
            Find Duplicates
            Iterates through a directory and obtains the file's hashcode within the directory.
            If the hashcode exists in the hashcode hashtable, then a duplicate exist. Otherwise,
            store it into the hashtable as a unique value. 
        #>
        foreach ($dir in $DirList) {

            Write-Verbose "$(Get-Date): Checking directory: $dir"
            $HashArray = @{}
            $HashInfo = @{}
            $Duplicates = @{}
            $HashCounter = 1
            $DupCounter = 1
            $csvLineNumber = 0

            $files = get-childitem -path $dir -file | Sort-Object -Property LastWriteTime -Descending

            foreach ($file in $files) {

                $get_FileHash = Get-FileHash -path $file.fullname
                try {
                    $FileHash = $get_FileHash.hash
                }
                catch [System.Management.Automation.PropertyNotFoundException] {
                    Write-Warning "MINOR: No hash value on $($file.name)"
                    continue
                }
                ## Hashtable will have unique values of hashcode ##
                if ($HashArray.ContainsValue($FileHash)) {
                    Write-Verbose "$(Get-Date): Duplicate found in Directory: $($dir) | File: $($file.name) "
                    $Duplicates.add($DupCounter++, $file.name)
                    if ($csvLineNumber++ -eq 0) {
                        $file | Add-Member @{VHD = $name}

                    }
                    else {
                        $file | Add-Member @{VHD = ' '}
                    }

                    $file | Add-Member @{Folder = $dir}
                    $file | Add-Member @{Original = $HashInfo[$FileHash]}
                    $file | Add-Member @{Duplicate = $file.fullname}

                    if ($Csvpath -ne "") {
                        $fileProperties = $file | Select-Object -Property VHD, Folder, Original, Duplicate
                        $fileProperties | export-Csv -path $Csvpath -NoTypeInformation -Append -Force
                    }
                }
                else {
                    ## Add first occuring hash code of a file ##
                    $HashInfo.add($FileHash, $file.name) # Unique Hash Code identifer
                    $HashArray.Add($HashCounter++, $FileHash)
                }
            }#foreach file

            if ($Duplicates.Count -eq 0) {
                Write-Verbose "$(Get-Date): No duplicates found in $dir"
            }
            else {
                Write-Verbose "$(Get-Date): Found $($duplicates.Count) duplicates in $dir"
            }

            ## User wants to delete duplicate files ##
            if ($remove) {
                foreach ($fp in $Duplicates.Values) {
                    $filename = split-path -path $fp -leaf
                    try {
                        Write-Verbose "$(Get-Date): Removing duplicate file: $filename"
                        remove-item -path $fp -Force
                    }
                    catch {
                        Write-Error $Error[0]
                    }
                }
            }


        }#foreach dir

        $Dirlist.Clear()


        ## Finish process ##
        dismount-FslDisk -path $path
    }#process

    end {
        $opt.WarningBackgroundColor = "Black"
        $opt.WarningForegroundColor = "Yellow"
    }
}
