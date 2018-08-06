function Get-FslAvailableDriveLetter {
    <#
        .SYNOPSIS
        Returns next available driveletter that is not mapped.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk
    #>

    Param(
        [Parameter(Position = 0)]
        [Switch]$Next
    )
    ## Start at D rather than A since A-B are floppy drives and C is used by main operating system.
    $Letters = [char[]](68..90)
    <#if($all -or $NextAvailableAll){

        $Drives = Get-PsDrive -PSProvider "FileSystem"
        $AvailableLetters = ($Letters).Where({$_.name -notin $Drives.Name})
    }else{ ## Finds all available driveletters that are unmapped

        $UsedLetters = Get-Wmiobject -class "win32_logicaldisk"
        $Mapped_Letters = $UsedLetters.DeviceID.substring(0,1)
        $AvailableLetters = ($Letters).where({$_ -notin $Mapped_Letters})
    }#>
    $AvailableLetters = New-Object System.Collections.ArrayList
    foreach ($letter in $Letters) {

        $Used_Letter = Get-PsDrive -Name $letter -ErrorAction SilentlyContinue
       
        if ($null -eq $Used_Letter) {
            $null = $AvailableLetters.add($letter)
        }
    }

    if($Next){
        Write-Output $AvailableLetters | select-object -first 1
    }else{
        Write-Output $AvailableLetters
    }
 
}

