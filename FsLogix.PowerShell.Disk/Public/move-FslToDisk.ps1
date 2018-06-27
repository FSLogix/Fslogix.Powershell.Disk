function move-FslToDisk {
    <#
        .SYNOPSIS
        Moves files/folders to a vhd.

        .PARAMETER VhdPath
        The user specified VHD path. Path can either be a folder containing VHD's
        or an individual disk. If user inputs a folder path, it'll transfer the files
        to all the disks in this folder path.

        .PARAMETER FilePath
        The user's filepath location. This file will be transfered to the disks.

        .PARAMETER Destination
        User's file destination within VHD.

        .PARAMETER Overwrite
        Validates if the user wants to ovewrrite pre-existing files within the disk 
        with the same name.

        .EXAMPLE
        move-fsltodisk -path "C:\users\danie\ODFC\test1.vhd" -Filepath "C:users\danie\Desktop\Contents" -Destination "test"
        Will obtain the VHD, test1.vhd, and transfer the files on the user's desktop called "Contents"
        within the VHD folder, test.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [Alias("path")]
        [System.string]$VhdPath,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)]
        [System.string]$FilePath,

        [Parameter(Position = 2, Mandatory = $false, ValueFromPipeline = $true)]
        [System.string]$Destination,

        [Parameter(Position = 3, Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("Yes", "No")]
        [System.string]$Overwrite = "no"
    )
    
    begin {
        ## Helper function to validate requirements
        Get-Requirements
    }
    
    process {

        ## Test paths ##
        if (-not(test-path -path $VhdPath)) {
            Write-Error "Could not validate: $vhdpath"
            exit
        }

        if (-not(test-path -path $FilePath)) {
            Write-Error "Could not validate: $filepath"
            exit
        }

        Write-Verbose "Obtaining VHD's."
        $VhdDetails = get-fslvhd -path $vhdpath

        Write-Verbose "Transfering files to VHD(s)"
        
        foreach ($vhd in $VhdDetails) {

            $DriveLetter = get-driveletter -path $vhd.path
            $VHD_File_Location = join-path($DriveLetter) ($Destination)

            if (-not(test-path -path $VHD_File_Location)) {
                Write-Error "Could not find path: $VHD_FILE_LOCATION"
                dismount-FslDisk -path $vhd.path
                break;
            }

            Write-Verbose "Transfering file contents to $VHD_File_location"
            
            switch ($Overwrite) {
                "Yes" {
                    try{
                        move-item -path $FilePath -Destination $VHD_File_Location -Recurse -Force
                        Write-Verbose "Transfered file contents to $VHD_File_Location"
                    }catch{
                        Write-Error $Error[0]
                    }
                }
                "No" {
                    try{
                        move-item -path $FilePath -Destination $VHD_File_Location -Recurse
                    }catch{
                        Write-Warning "Item already exists. User opted to not overwrite."
                    }
                }
            }
           
            dismount-fsldisk -path $vhd.path -ErrorAction SilentlyContinue
        }
    }
    
    end {
    }
}