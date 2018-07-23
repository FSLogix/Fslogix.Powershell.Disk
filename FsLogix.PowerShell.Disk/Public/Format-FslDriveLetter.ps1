function Format-FslDriveLetter {
    <#
        .SYNOPSIS
        Function to either get, set, or remove a disk's driveletter.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER VHDpath
        Path to a specificed VHD or directory of VHD's.

        .PARAMETER Command
        User command to either get a driveletter, set a driveletter, or remove a driveletter.

        .PARAMETER Letter
        Letter to assign if user opts to set a drive letter

        .EXAMPLE
        format-fsldriveletter -path C:\users\danie\documents\ODFC\test1.vhd -get

        .EXAMPLE
        format-fsldriveletter -path C:\users\danie\documents\ODFC\test1.vhd -set -letter T
        Assigns drive letter 'T' to test1.vhd

        .EXAMPLE
        format-fsldriveletter -path C:\users\danie\documents\ODFC\test1.vhd -remove
        Remove's the driveltter on test1.vhd
    #>
    [CmdletBinding(DefaultParametersetName='None')]
    param (

        [Parameter(Position = 0, Mandatory = $true,
        ValueFromPipeline = $true)]
        [alias("path")]
        [System.String]$VhdPath,

        [Parameter(Position = 1, ParameterSetName = 'GetDL')]
        [Switch]$Get,

        [Parameter(Position = 2, ParameterSetName = 'RemoveDL')]
        [Switch]$Remove,

        [Parameter(Position = 3, ParameterSetName = 'SetDL')]
        [Switch]$Set,

        [Parameter(Position = 2, ParameterSetName = 'SetDL',Mandatory = $true)]
        [ValidatePattern('^[a-zA-Z]')]
        [System.Char]$Letter


    )

    begin {
        set-strictmode -Version latest
    }

    process {
        ## Helper function to retrieve VHD's. Will handle errors ##
        $VHDs = get-fslvhd -Path $VhdPath

        ## Helper FsLogix functions, Get-DriveLetter, Set-FslDriveletters, remove-fslDriveletter, and dismount-fsldisk ##
        ## Will validate error handling.                                                                               ##
        foreach ($vhd in $VHDs) {

            if ($Get) {
                get-driveletter -VHDPath $vhd.path
                dismount-FslDisk -path $vhd.path
            }
            if ($Set) {
                Set-FslDriveLetter -VHDPath $vhd.path -Letter $letter
            }
            if ($Remove) {
                Remove-FslDriveLetter -Path $vhd.path
            }
        }
    }

    end {
    }
}