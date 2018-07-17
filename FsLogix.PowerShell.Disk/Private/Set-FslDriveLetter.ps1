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

        if(-not(test-path -path $VHDPath)){
            Write-Error "Could not find path: $VHDPath" -ErrorAction Stop
        }

        $VHDs = Get-FslDisk -path $VHDPath
        if ($null -eq $VHDs) {
            Write-Warning "Could not find any VHD's in path: $VHDPath" -WarningAction Stop
        }

        $AvailableLetters = Get-FslAvailableDriveLetter

        $NewLetter = "$Letter" + ":"
        $Available = $false

        if($AvailableLetters -contains $Letter){
            $Available = $true
        }

        if($Available -eq $false){
            Write-Error "DriveLetter '$($Letter):\' is not available. For available driveletters, type cmdlet: Get-FslAvailableDriveLetter" -ErrorAction Stop
        }

        foreach ($vhd in $VHDs) {
            $name = split-path -path $vhd.path -leaf
            $DL = Get-driveletter -VHDPath $vhd.path
            $subbedDL = $DL.substring(0,2)

            try {
                $drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = '$subbedDl'" | out-null
            }
            catch {
                Write-Verbose "$(Get-Date): Could not change $name's Driveletter to $letter."
                Write-Error $Error[0]
                exit
            }

            try {
                $drive | Set-WmiInstance -Arguments @{DriveLetter = $NewLetter} | Out-Null
            }
            catch {
                Write-Verbose "$(Get-Date): Could not change $name's Driveletter to $letter."
                Write-Error $Error[0]
            }

            Write-Verbose "$(Get-Date): Succesfully changed $name's Driveletter to $letter."
            dismount-FslDisk -path $Vhd.path
        }
    }
    end {
    }
}