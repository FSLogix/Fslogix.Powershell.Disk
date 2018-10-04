$Public = @( Get-ChildItem -Path 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.PowerShell.disk\Functions\Public' -filter "*.ps1")
$Private = @( Get-ChildItem -Path 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.PowerShell.disk\Functions\Private' -filter "*.ps1")
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
