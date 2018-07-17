function copy-FslToDisk {
    <#
        .SYNOPSIS
        Copies files/folders to a vhd.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER VhdPath
        The user specified VHD path. Path can either be a folder containing VHD's
        or an individual disk. If user inputs a folder path, it'll copy the files
        to all the disks in this folder path.

        .PARAMETER FilePath
        The user's filepath location. This file will be transfered to the disks.

        .PARAMETER Destination
        User's file destination within VHD.

        .PARAMETER Overwrite
        Validates if the user wants to ovewrrite pre-existing files within the disk
        with the same name.

        .EXAMPLE
        copy-fsltodisk -path "C:\users\danie\ODFC\test1.vhd" -Filepath "C:users\danie\Desktop\Contents" -Destination "test"
        Will obtain the VHD, test1.vhd, and transfer the files on the user's desktop called "Contents"
        within the VHD folder, test.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("path")]
        [System.string]$VhdPath,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.string]$FilePath,

        [Parameter(Position = 2, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.string]$Destination,

        [Parameter(Position = 3)]
        [Switch]$Overwrite,

        [Parameter(Position = 4)]
        [Switch]$dismount,

        [Parameter(Position = 5)]
        [switch]$recurse
    )

    begin {
        set-strictmode -Version latest
    }

    process {

        ## Test paths ##
        if (-not(test-path -path $VhdPath)) {
            Write-Error "Could not validate: $vhdpath" -ErrorAction stop
        }

        if (-not(test-path -path $FilePath)) {
            Write-Error "Could not validate: $filepath" -ErrorAction Stop
        }

        $VhdDetails = get-fslvhd -path $vhdpath

        foreach ($vhd in $VhdDetails) {

            ## FSL Drive Letter helper function
            $DriveLetter = get-driveletter -path $vhd.path
            $VHD_File_Location = join-path($DriveLetter) ($Destination)

            if (-not(test-path -path $VHD_File_Location)) {
                Write-Error "Could not find path: $VHD_FILE_LOCATION" -ErrorAction Stop
            }

            Write-Verbose "$(Get-Date): Copying file contents to $VHD_FILE_LOCATION"
            $Command = "copy-item -path $FilePath -Destination $VHD_File_Location"
            if($Overwrite){
                $Command += " -force"
            }
            if($recurse){
                $Command += " -Recurse"
            }
            try{
                Invoke-Expression $Command
                Write-Verbose "$(Get-Date): Copied $FilePath to $VHD_File_Location"
            }catch{
                Write-Error $Error[0]
            }
            if ($dismount) {
                dismount-fsldisk -path $vhd.path -ErrorAction SilentlyContinue
            }
        }
    }

    end {
    }
}