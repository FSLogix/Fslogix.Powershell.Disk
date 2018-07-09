function Get-FslAvailableDriveLetter{

    $Letters = [char]'D'..[Char]'Z' | ForEach-Object { "$([char]$_)" } 
        
    $GetLetters = $Letters | where-Object { 'h:', 'k:', 'z:' -notcontains $_  } 
        
    $AvailableLetters = $GetLetters | Where-Object { (new-object System.IO.DriveInfo $_).DriveType -eq 'noRootdirectory' }
 
    Write-Output $AvailableLetters
}