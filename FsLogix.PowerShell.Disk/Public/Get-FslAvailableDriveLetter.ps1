function Get-FslAvailableDriveLetter {
    <#
        .SYNOPSIS
        Returns next available driveletter that is not mapped.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER NextAvailable
        Optional input to return next unmapped avilable drive letter

        .PARAMETER All
        Optional input to return all available drive letters mapped or unmapped

        .PARAMETER NextAvailableAll
        Optional input to return next available drive letter mapped or unmapped

        .EXAMPLE
        Get-FslAvailableDriveLetter
        Returns all unmapped Drive Letters that are ready to use.

        .EXAMPLE
        Get-FslAvailableDriveLetter -NextUnmapped
        Returns the next available drive letter that's unmapped and ready to use

        .EXAMPLE
        Get-FslAvailableDriveLetter -Next
        Returns the next available drive letter that's either mapped or unmapped.

        .EXAMPLE
        Get-FslAvailableDriveLetter -All
        Returns all available drive letters that's either mapped or unmapped
    #>

    Param(
        [Parameter(Position = 0)]
        [Alias("NextUnmapped")]
        [Switch]$NextAvailable,

        [Parameter(Position = 1)]
        [Alias("Next")]
        [Switch]$NextAvailableAll,

        [Parameter(Position = 2)]
        [switch]$All
    )
    ## Start at D rather than A since A-B are floppy drives and C is used by main operating system.
    $Letters = [char[]](68..90)

    
        <#
            Not all disks are 'FileSystem'
            Doesn't find network drives, disconnected network drives, etc
            Not all disks are logical disks
            Ex: Printer, disconnected network drives
            *NAIVE SOLUTION*
            Have the disk try to use every drive letter in a while loop.
            
            If all are used, need a solution for that.
            mount
            *SOLUTION*
            Use guid path
    
        #>

    if($all -or $NextAvailableAll){

        $Drives = Get-PsDrive -PSProvider "FileSystem"
        $AvailableLetters = ($Letters).Where({$_.name -notin $Drives.Name})
    }else{ ## Finds all available driveletters that are unmapped

        $UsedLetters = Get-Wmiobject -class "win32_logicaldisk"
        $Mapped_Letters = $UsedLetters.DeviceID.substring(0,1)
        $AvailableLetters = ($Letters).where({$_ -notin $Mapped_Letters})
    }
 
    if($null -eq $AvailableLetters){
        Write-Warning "There are no available driveletters."
        exit
    }

    if ($NextAvailable -or $NextAvailableAll) {
        Write-Output $AvailableLetters | Select-Object -first 1
    }else{
        Write-Output $AvailableLetters
    }
}

