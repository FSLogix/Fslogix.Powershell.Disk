function Get-FslAvailableDriveLetter {
 
    Param(
        [Parameter(Position = 0)]
        [Switch]$Next
    )
    ## Start at D rather than A since A-B are floppy drives and C is used by main operating system.
    $Letters = [char[]](68..90)
    <#$AvailableLetters = New-Object System.Collections.ArrayList
    foreach ($letter in $Letters) {
        $Used_Letter = Get-PsDrive -Name $letter -ErrorAction SilentlyContinue
        if ($null -eq $Used_Letter) {
            $null = $AvailableLetters.add($letter)
        }
    }#>
    $AvailableLetters = $Letters | Where-Object {!(test-path -Path "$($_):")}
    if ($Next) {
        Write-Output $AvailableLetters | select-object -first 1
    }
    else {
        Write-Output $AvailableLetters
    }
 
}