#Requires -Modules "Hyper-V"
function move-FslToDisk {
    <#
        .SYNOPSIS
        Moves files/folders to a vhd.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

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
        [Switch]$dismount
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

            Write-Verbose "$(Get-Date): Moving file contents to $VHD_FILE_LOCATION"

            if ($Overwrite) {

                try {
                    move-item -path $FilePath -Destination $VHD_File_Location -Force
                    Write-Verbose "$(Get-Date): Transfered file contents to $VHD_File_Location"
                }
                catch {
                    Write-Error $Error[0]
                }
            }else{

                try {
                    #Don't need recurse parameter, is automatically recurses
                    move-item -path $FilePath -Destination $VHD_File_Location
                }
                catch {
                    Write-Error $Error[0]
                }

            }
            if($dismount){
                dismount-fsldisk -path $vhd.path -ErrorAction SilentlyContinue
            }
        }
    }

    end {
    }
}