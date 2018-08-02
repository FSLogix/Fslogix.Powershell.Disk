function Format-FslDriveLetter {
    <#
        .SYNOPSIS
        Function to either get, set, or remove a disk's driveletter.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER Get
        Returns the driveletter associated with the VHD. If none is available, returns the path.

        .PARAMETER Remove
        Removes the driveletter associated with the VHD.

        .PARAMETER Set
        Sets a driveletter to a vhd

        .PARAMETER Letter
        User associated letter when setting vhd's driveletter

        .PARAMETER Assign
        Automatically assigns a driveletter, starting from Z.

        .EXAMPLE
        format-fsldriveletter -path C:\users\danie\documents\ODFC\test1.vhd -get

        .EXAMPLE
        format-fsldriveletter -path C:\users\danie\documents\ODFC\test1.vhd -set -letter T
        Assigns drive letter 'T' to test1.vhd

        .EXAMPLE
        format-fsldriveletter -path C:\users\danie\documents\ODFC\test1.vhd -remove
        Remove's the driveltter on test1.vhd
    #>
    [CmdletBinding(DefaultParametersetName = 'None')]
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

        [Parameter(Position = 4, ParameterSetName = 'SetDL', Mandatory = $true)]
        [ValidatePattern('^[a-zA-Z]')]
        [System.Char]$Letter,

        [Parameter(Position = 5, ParameterSetName = 'AssignDL')]
        [Switch]$Assign,

        [Parameter(Position = 6, ParameterSetName = 'index', Mandatory = $true)]
        [int]$Start,

        [Parameter(Position = 7, ParameterSetName = 'index', Mandatory = $true)]
        [int]$End


    )

    begin {
        set-strictmode -Version latest
    }

    process {
        ## Helper function to retrieve VHD's. Will handle errors ##
        $VHDs = get-fslvhd -Path $VhdPath -start $start -end $end

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
            if ($Assign) {
                if($vhd.attached){
                    Write-Warning "VHD Currently in use. Dismounting disk"
                    Dismount-fsldisk $vhd.path
                }
                $Driveletterassigned = $false
                $letter = [int][char]'Z'
                while ($DriveLetterAssigned -eq $false) {
                    try {
                        $mount = Mount-DiskImage -ImagePath $vhd.path -NoDriveLetter -PassThru -ErrorAction Stop | get-diskimage
                        $Disk = $mount | get-disk -ErrorAction Stop
                        $Partition = $Disk | get-partition -ErrorAction Stop
                        $Partition | Where-Object {$_.type -eq 'basic'} | set-partition -NewDriveLetter $letter -ErrorAction Stop 
                        if ($Letter -eq 'C') {
                            Write-Error "Cannot find free drive letter"
                            exit
                        }
                        $DriveLetterAssigned = $true
                    }
                    catch {
                        $letter --
                    }
                }
                if($Driveletterassigned){
                    Write-Verbose "Assigned DriveLetter: $([char]$letter)."
                }
                dismount-FslDisk $vhd.path
            }
        }
    }

    end {
    }
}