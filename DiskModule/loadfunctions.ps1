$Public = @( Get-ChildItem -Path 'C:\Users\danie\Documents\DiskModule\Functions\Public')
$Private = @( Get-ChildItem -Path 'C:\Users\danie\Documents\DiskModule\Functions\Private')
$verbosepreference = "continue"
#Dot source the filesd
Foreach ($import in @($Public + $Private)) {
    Try {
        Write-Verbose "Loading $($Import.FullName)"
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}
