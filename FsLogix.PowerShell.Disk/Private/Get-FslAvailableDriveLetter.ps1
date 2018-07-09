function Get-FslAvailableDriveLetter {
    <#
        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk
    #>

    Param(
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Switch]$NextAvailable
    )
    ## Start at D rather than A since A-B are floppy drives and C is used by main operating system.
    $Letters = [char]'D'..[Char]'Z' | ForEach-Object { "$([char]$_)" } 

    ## This finds all available driveletters that are not mapped.
    $AvailableLetters = $Letters | Where-Object { (new-object System.IO.DriveInfo $_).DriveType -eq 'noRootdirectory' }
 
    if ($NextAvailable) {
        Write-Output $AvailableLetters | Select-Object -first 1
    }
    else {
        Write-Output $AvailableLetters
    }
}