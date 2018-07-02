function Get-FslDuplicates {
    <#
        .SYNOPSIS
        Returns any duplicate files within disk into a comma separated excel file.
        User can opt to have duplicate files removed.

        .PARAMETER vhdPath
        Path to a specified VHD or directory containing VHD's.

        .PARAMETER path
        Optional path within a VHD.

        .PARAMETER CsvPath
        User specified destination for csv file output. Must have .csv extension.

        .PARAMETER Remove_Duplicates
        Optional parameter if user wants to remove the duplicates.
        
        .EXAMPLE
        get-fslduplicates -vhdpath C:\Users\danie\Documents\ODFC -csvpath $env:temp\test.csv
        Script will retrieve all VHD's in C:\Users\Danie\Documents\ODFC and search for duplicates.
        The duplicate files data will then be exported to a csv file located in the user's temp folder.

        .EXAMPLE
        get-fslduplicates -vhdpath C:\Users\danie\documents\ODFC -path Daniel\kim\ -csvpath $env:temp\test.csv
        Script will retrieve all VHDs and serach for duplicates in the 'Daniel\Kim\' directory within the VHD.

        .EXAMPLE
        get-fslduplicates -vhdpath C:\Users\danie\documents\ODFC -csvpath $env:temp\test.csv -confirm true
        Script will retrieve all VHD's and search for duplicates. The duplicate files data will be exported to 
        a csv file and then the script will remove all the duplicates.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, 
            Mandatory = $true, 
            ValueFromPipeline = $true,
            HelpMessage = 'Path to specified VHD or directory containing VHDs' )]
        [System.String]$vhdPath,

        [Parameter(Position = 1, 
            Mandatory = $false, 
            ValueFromPipeline = $true,
            HelpMessage = 'Specific directory search within a VHD')]
        [System.String]$Path,

        [Parameter(Position = 2,
            Mandatory = $false,
            HelpMessage = 'CSV output file detailing duplicate files')]
        [System.String]$Csvpath,

        [Parameter(Position = 3, Mandatory = $false, ValueFromPipeline = $true)]
        [Alias("Confirm")]
        [ValidateSet("True", "False")]
        [System.String]$Remove_Duplicates = "false",

        [Parameter(Position = 3, Mandatory = $false, ValueFromPipeline = $true)]
        [System.String]$log
    )
    
    begin {        
        ## Helper function to validate requirements
        function get-FslDuplicateFiles {
            [CmdletBinding()]
            param (
                [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
                [System.String]$path,
        
                [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true)]
                [System.String]$Folderpath,
        
                [Parameter(Position = 2, Mandatory = $false, ValueFromPipeline = $true)]
                [System.String]$Csvpath,
        
                [Parameter(Position = 3, Mandatory = $false, ValueFromPipeline = $true)]
                [ValidateSet("True", "False")]
                [System.String]$Remove
            )
            
            begin {
                set-strictmode -Version latest
            }
            
            process {
                $name = split-path -path $path -leaf
        
                ## Helper functions built in will help with error checking ##
                $DriveLetter = get-Driveletter -path $path
                $Path_To_Search = join-path ($DriveLetter)($folderpath)
                Write-Verbose "Searching for Duplicates in $path"
        
                if (-not(test-path -path $Path_To_Search)) {
                    Write-Warning "$name : Could not find path: $Path_To_Search"
                }
        
                $dirlist = New-Object System.Collections.Queue
                $dirlist.Enqueue($Path_To_Search)
                $Directories = get-childitem -path $Path_To_Search -Recurse | Where-Object { $_.PSIsContainer } | Select-Object FullName

                foreach ($dir in $Directories) {
                    $dirlist.Enqueue($dir.FullName)
                }
          
                ## Find Duplicate Algorithm ##
                foreach ($dir in $DirList) {
        
                    Write-Verbose "Checking directory: $dir"
                    $HashArray = @{}
                    $HashInfo = @{}
                    $Duplicates = @{}
                    $HashCounter = 1
                    $DupCounter = 1
                    $csvLineNumber = 0
                    
                    $files = get-childitem -path $dir | Sort-Object -Property LastWriteTime -Descending
                    foreach ($file in $files) {
                        try {
                            ## Get File's hash value, skipping if folder ##
                            $get_FileHash = Get-FileHash -path $file.fullname
                            $FileHash = $get_FileHash.hash
                            Write-Verbose "Obtained $file's hash value."
                        }
                        catch [System.Management.Automation.PropertyNotFoundException] {
                            Write-Warning "'$file' is a directory... Skipping."
                            continue
                        }
        
                        ## Hashtable will have unique values of hashcode ##
                        if ($HashArray.ContainsValue($FileHash)) {
                            Write-Verbose "Duplicate found!"
                            $Duplicates.add($DupCounter++, $file.fullname)
                            if ($csvLineNumber++ -eq 0) {
                                $file | Add-Member @{VHD = $name}
        
                            }
                            else {
                                $file | Add-Member @{VHD = ' '}
                            }
                        
                            $file | Add-Member @{Folder = $dir}
                            $file | Add-Member @{Original = $HashInfo[$FileHash]}
                            $file | Add-Member @{Duplicate = $file.name}
                            $file | Add-Member @{DuplicateCreationDate = $file.creationtime}
                            $file | Add-Member @{FileSize_GB = [Math]::Round($file.length/1gb,2)}
                            $file | Add-Member @{FileSize_MB = [Math]::Round($File.length/1mb, 2)}
                       
                            if ($Csvpath -ne "") {
                                $fileProperties = $file | Select-Object -Property VHD, Folder, Original, Duplicate, DuplicateCreationDate, FileSize_GB, FileSize_MB
                                $fileProperties | export-Csv -path $Csvpath -NoTypeInformation -Append -Force
                            }
                        }
                        else {
                            ## Add first occuring hash code of a file ##
                            $HashInfo.add($FileHash, $file.name) # Unique Hash Code identifer
                            $HashArray.Add($HashCounter++, $FileHash) 
                        }
                    }#foreach file
                    ## User wants to delete duplicate files ##
                    if ($remove -eq "true") {
                        foreach ($fp in $Duplicates.Values) {
                            $filename = split-path -path $fp -leaf
                            try {
                                Write-Verbose "Removing duplicate file: $filename"
                                remove-item -path $fp -Force
                            }
                            catch {
                                Write-Error $Error[0]
                            }
                        }
                    }
                    if ($Duplicates.Count -eq 0) {
                        Write-Verbose "No duplicates found in $dir"
                    }
                    else {
                        Write-Verbose "Found $($duplicates.Count) duplicates in $dir"
                    }
                
                }#foreach dir
                $dirlist.Clear()
            
                
                
            }#process
            
            end {
                ## Finish process ##
                dismount-FslDisk -path $path
            }
        }#get-fslduplicatefiles
        function Get-Requirements {
            [CmdletBinding()]
            param (
                
            )
            
            begin {
            }
            
            process {
                Write-Verbose "Setting latest version of PowerShell..."
                Set-StrictMode -Version latest
                Write-Verbose "Latest version set!"
        
                Write-Verbose "Checking if Hyper-V is installed..."
                if (((Get-Module -ListAvailable).Name -notcontains 'Hyper-V')) {
                    Write-Verbose "Hyper-V does not exist..."
                    Write-Error "Hyper-V must be installed to use this script."
                }
                else {
                    Write-Verbose "Hyper-V found!"
                }
        
                Write-Verbose "Checking if in administrator mode..."
                If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
                    Write-Verbose "Validated administrator mode!"
                }
                else {
                    Write-Error "Script must be ran in administrator mode."
                }
                
            }
            
            end {
            }
        }#get-requirements
        function Get-FslVHD {
            <#
                .SYNOPSIS
                Retrives all VHD's within a path and returns their information.
                
                .DESCRIPTION
                Searches in a given path for all VHD's. User can either input a directory path or
                a path to an indivudal VHD. Once all the VHD's are found, if found, return the amount
                found and then outputs the VHD's information. 
            #>
            [CmdletBinding()]
            param (
                [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
                [System.String]$path
            )
            
            begin {
                set-strictmode -Version latest
            }
            
            process {
        
                if (-not(test-path -path $path)) {
                    write-error "Path: $path is invalid."
                    exit
                }
                
                $VHDs = get-childitem -path $path -filter "*.vhd*" -Recurse
                if ($null -eq $VHDs) {
                    write-error "Could not find any VHDs in path: $path"
                    exit
                }
        
                $VhdDetails = $VHDs.FullName | get-fsldisk
                try {
                    $count = $VhdDetails.count
                }
                catch [System.Management.Automation.PropertyNotFoundException] {
                    # When calling the get-childitem cmdlet, if the cmldet only returns one
                    # object, then it loses the count property, despite working on terminal.
                    $count = 1 
                }
                write-verbose "Retrieved $count VHD(s)."
        
                Write-Output $VhdDetails
            }
            
            end {
                
            }
        }#get-fslvhd
        function get-driveletter {
            <#
                .NOTES
                Created on 6/6/18
                Created by Daniel Kim @ FSLogix    
                Created by Jim Moyle @ FSLogix
                .SYNOPSIS
                Obtains a virtual disk and returns the Drive Letter associated with it.
                If either Drive Letter is null or invalid, the script will assign the
                next available drive letter.
                .DESCRIPTION
                This function can be added to any script that requires mounting 
                a vhd and accessing it's contents.
                .PARAMETER VHDPath
                The target path for VHD location.
                .EXAMPLE
                mount-FSLVHD -path \\server\share\ODFC\vhd1.vhdx
                Will return the drive letter
            #>
        
            param(
                [Parameter(Position = 0, Mandatory = $true)]
                [Alias("path")]
                [string]$VHDPath
            )
            begin {
                Set-StrictMode -Version Latest
                $Attached = $false
            }
            process {
            
                Write-Verbose "Validating path: $VHDPath"
                if (test-path $VHDPath) {
                    Write-Verbose "$VHDPath is valid."
                }
                else {
                    Write-Error "$VHDPath is invalid."
                    exit
                }
        
                ## Helper function ##
                $VHDProperties = get-fsldisk -path $VHDPath
        
                if ($VHDProperties.Attached -eq $true) { $Attached = $true }
        
                if ($Attached) {
                
                    ## If disk is already mounted, can skip mounting process. ##
                    $disk = Get-Disk | Where-Object {$_.Location -eq $VHDPath}
                    $driveLetter = $disk | Get-Partition | Select-Object -ExpandProperty AccessPaths | Select-Object -first 1
        
                }
                else {
                    try {
                        ## Need to mount ##
                        $mount = Mount-VHD -path $VHDPath -Passthru -ErrorAction Stop
                        Write-Verbose "VHD succesfully mounted."
                    }
                    catch {
                        write-error $Error[0]
                        Write-Error "Could not mount VHD. Perhaps the VHD Path."
                        break
                    }
                    $driveLetter = $mount | Get-Disk | Get-Partition | Select-Object -ExpandProperty AccessPaths | Select-Object -first 1
                }
                
                ## This bug usually occurs because the Driveletter associated with the disk is already in use. ##
                if ($null -eq $driveLetter) {
                    try {
                        $disk = Get-Disk | Where-Object {$_.Location -eq $VHDPath}
                        $disk | set-disk -IsOffline $false
                    }
                    catch {
                        Write-Error $Error[0]
                    }
                    $driveLetter = $disk | Get-Partition | Select-Object -ExpandProperty AccessPaths | Select-Object -first 1
                }
                
                ## A drive letter was never initialized to the VHD ##
                if ($driveLetter -like "*\\?\Volume{*") {
        
                    Write-warning "Driveletter is invalid: $Driveletter. Reassigning Drive Letter."
                    if ($Attached) {
                        $disk = Get-Disk | Where-Object {$_.Location -eq $VHDPath}
                        $driveLetter = $disk | Get-Partition | Add-PartitionAccessPath -AssignDriveLetter
                    }
                    else {
                        $driveLetter = $mount | get-disk | Get-Partition | Add-PartitionAccessPath -AssignDriveLetter 
                    }
                    if ($null -eq $driveLetter) {
        
                        ## If the VHD is mounted, then the assigned driver letter won't be updated.
                        ## Have to dismount and remount for the drive letter to be updated.
                        ## Perhaps there is a way to prevent this and speed the script up.
        
                        ## Update 1 Tried using 'Update-disk', the function will then return wrong drive letter
        
                        try {
                            Write-Verbose "Remounting VHD."
                            Dismount-VHD $VHDPath -Passthru -ErrorAction Stop
                        }
                        catch {
                            Write-Error $Error[0]
                            Write-Error "Failed to Dismount $VHDPath vhd will need to be manually dismounted"
                        }
        
                        try {
                            $mount = mount-vhd -path $VHDPath -Passthru -ErrorAction stop
                            $driveLetter = $mount | get-disk | Get-Partition | Select-Object -ExpandProperty AccessPaths | Select-Object -first 1
                            Write-Verbose "Remounted VHD"
                        }
                        catch {
                            Write-Error "Could not remount VHD"
                            break
                        }
                    
                    }#end if(null) 
                }#end if {volume}
                else {
                    Write-Verbose "VHD mounted on drive letter [$DriveLetter]"
                }#end else
        
                Write-Output $driveLetter
                #return $driveLetter
            }#end process
            end {
            }
        }#get-driveletter
        function Get-FslDisk {
            <#
                .SYNOPSIS
                Returns a VHD's properties and it's information/values.
        
                .DESCRIPTION
                Helper function for Get-FslVHD
                Obtains a single VHD.
                The script will return the respective VHD's properties and it's information/values.
        
                .PARAMETER path
                User specified path location to a VHD. Must include .vhd/.vhdx extension
                .EXAMPLE
                get-FslVHD -path C:\Users\Daniel\ODFC\test1.vhd
                Will return the properties associated with test1.vhdKs
            #>
            [CmdletBinding()]
            param (
                [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
                [System.String]$Path
            )
            
            begin {
                set-strictmode -Version latest
            }
            
            process {
        
                Write-Verbose "Confirming path..."
                if (test-path -path $Path) {
                    write-verbose "Path confirmed."
                }
                else {
                    write-error $error[0]
                    exit
                }
        
                Write-Verbose "Confirming Extension..."
                if ($path -like "*.vhd*") {
                    write-verbose "Extension confirmed..."
                    $name = split-path -path $path -leaf
                    try {
                        Write-Verbose "Obtaining VHD: $name's information"
                        $VHDInfo = $Path | get-vhd
                    }
                    catch {
                        Write-Error $Error[0]
                        exit
                    }
                    Write-Output $VHDInfo
                }
                else { 
                    Write-Error "File path should include a .vhd or .vhdx extension."
                    exit
                }
            }
            end {
            }
        }#get-fsldisk
        function dismount-FslDisk {
            <#
                .SYNOPSIS
                Dismounts a VHD or dismounts currently existing attached VHDs.
        
                .DESCRIPTION
                This function can be added to any script that requires dismounting
                a vhd.
        
                .PARAMETER VHDPath
                Optional target path for VHD location.
        
                .EXAMPLE
                dismount-FSLDisk -path \\server\share\ODFC\vhd1.vhdx
                Will dismount vhd1.vhdx
        
                .EXAMPLE
                dismount-fslDisk
                Will dismount all currently attached VHD's.
            #>
            [CmdletBinding()]
            param (
                [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
                [Alias("Path")]
                [System.String]$FullName
            )
            
            begin {
                set-strictmode -version latest
            }#begin
            
            process {
                if ($FullName -ne "") {
                    $name = split-path -Path $FullName -Leaf
                    try {
                        write-verbose "Dismounting $name"
                        Dismount-VHD -Path $FullName -ErrorAction Stop
                        Write-Verbose "Successfully dismounted $name"
                    }
                    catch {
                        write-error $Error[0]
                        exit
                    }
                }
                else {
                    
                    Write-Verbose "Getting all currently attached disks..."
                    $Get_Attached_VHDs = Get-Disk | select-object -Property Model, Location
        
                    if ($null -eq $Get_Attached_VHDs) {
                        Write-Warning "Could not find any attached VHD's. Exiting script..."
                        Exit
                    }
                    else {
                        Write-Verbose "Dismounting attached disks..."
                        foreach ($vhd in $Get_Attached_VHDs) {
                            if ($vhd.Model -like "Virtual Disk*") {
                                $name = split-path -path $vhd.location -Leaf
                                try {
                                    Write-Verbose "Dismounting VHD: $name"
                                    Dismount-VHD -path $vhd.location -ErrorAction Stop
                                    Write-Verbose "Succesfully dismounted VHD: $name"
                                }
                                catch {
                                    Write-Error $Error[0]
                                }
                            }
                            else {
                                Write-Warning "$($vhd.Model) is not a virtual disk. Skipping"
                            }
                        }
                    }
                    Write-Verbose "Finishing script."
                    
                }
            }#process
        
            end {
            }
        }#dismount-fsldisk
        
    
        ## Validate inputs ##
        if ($Remove_Duplicates -eq "true") {
            $Remove -eq $true
        }

        if ($path -ne "") {
            $check_If_Directory = [System.IO.Path]::GetExtension($path)
            if ($check_If_Directory -ne "") {
                Write-Error "$Path must be a directory."
                exit
            }
        }

        if ($Csvpath -ne "") {
            remove-item -path $Csvpath -Force -ErrorAction SilentlyContinue
        }

        $Remove = $false
    }#Begin
    
    process {

        Write-Verbose "Checking requirments..."
        Get-Requirements

        $VerbosePreference = "continue"
        start-transcript -LiteralPath $log

        ## Get VHDs ##
        Write-Verbose "Retrieving VHD(s)"
        $VHDs = get-fslvhd -path $vhdpath
        if ($null -eq $VHDs) {
            Write-Warning "Could not find VHDs in $vhdpath"
            exit
        }
        ## Search Duplicates ##
        foreach ($vhd in $VHDs) {
            get-FslDuplicateFiles -path $vhd.path -folderpath $Path -csvpath $Csvpath -remove $Remove_Duplicates
        }

        ## Convert .csv file into a formatted excel file ##
        if ($null -ne $Csvpath) {
            
            <### Code here ##
            $ConvertTo-CSV -csvpath $csvPath{
                $xlspath = split-path -path $csvpath 
                $xlspath += '\Test.xlsx'
                write-verbose "Creating Excel document to: $xlspath"
                remove-item -Path $xlspath -Force -ErrorAction SilentlyContinue
                $Csvpath
                $xlspath
                Import-Csv $Csvpath | Export-Excel $xlspath -AutoSize  
                remove-item -Path $Csvpath -Force -ErrorAction SilentlyContinue
            }#>
        }
        Write-Verbose "Finished Get-FslDuplicates script."
    }#process
    
    end {
        stop-transcript
    }
}