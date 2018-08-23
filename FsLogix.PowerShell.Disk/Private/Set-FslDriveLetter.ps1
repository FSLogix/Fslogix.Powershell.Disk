function Set-FslDriveLetter {
    <#
        .SYNOPSIS
        Set's a user specified Drive Letter to a virtual disk

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER VHDPath
        Path to a specified virtual disk or directory containing virtual disks.

        .PARAMETER Letter
        User specified drive letter

        .EXAMPLE
        Set-FslDriveLetter -path C:\Users\danie\documents\test\test1.vhd -letter F
        Script will set the drive letter attached to test1.vhd to letter, 'F'.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$VHDPath,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidatePattern('^[a-zA-Z]')]
        [System.Char]$Letter
    )

    begin {
        Set-StrictMode -Version latest
    }

    process {

        if (-not(test-path -path $VHDPath)) {
            Write-Error "Could not find path: $VHDPath" -ErrorAction Stop
        }

        $VHDs = Get-FslDisk -path $VHDPath
        if ($null -eq $VHDs) {
            Write-Warning "Could not find any VHD's in path: $VHDPath" -WarningAction Stop
        }

        $AvailableLetters = Get-FslAvailableDriveLetter

        $Available = $false

        if ($AvailableLetters -contains $Letter) {
            $Available = $true
        }

        if ($Available -eq $false) {
            Write-Error "DriveLetter '$($Letter):\' is not available. For available driveletters, type cmdlet: Get-FslAvailableDriveLetter" -ErrorAction Stop
        }
        $name = $vhds.name
        if ($vhds.attached) {
            $Disk = get-disk | where-object {$_.Location -eq $VHDPath}
        }
        else {
            $mount = Mount-DiskImage -ImagePath $vhdpath -NoDriveLetter -PassThru -ErrorAction Stop | get-diskimage
            $Disk = $mount | get-disk -ErrorAction Stop
        }
        $Partition = $Disk | get-partition -ErrorAction Stop
        $Partition | sort-object -property size | select-object -last 1 | set-partition -NewDriveLetter $letter -ErrorAction Stop 

        Write-Verbose "$(Get-Date): Succesfully changed $name's Driveletter to [$($letter):\]."
        dismount-FslDisk -path $Vhds.path
    
    }
    end {
    }
}