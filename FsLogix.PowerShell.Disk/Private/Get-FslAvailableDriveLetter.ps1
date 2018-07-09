function Get-FslAvailableDriveLetter{

    ## Start at D rather than A since A-B are floppy drives and C is used by main operating system.
    $Letters = [char]'D'..[Char]'Z' | ForEach-Object { "$([char]$_)" } 

    ## This finds all available driveletters that are not mapped.
    $AvailableLetters = $GetLetters | Where-Object { (new-object System.IO.DriveInfo $_).DriveType -eq 'noRootdirectory' }
 
    Write-Output $AvailableLetters
}
