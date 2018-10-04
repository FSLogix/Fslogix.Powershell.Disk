function Remove-FslDriveLetter {
    [CmdletBinding()]
    param (
        [Parameter( Position = 0, 
                    Mandatory = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [System.String]$Path
    )

    begin {
        Set-StrictMode -Version Latest
        #Requires -RunAsAdministrator
    }

    process {

        if (-not(test-path -path $path)) {
            Write-Error "Could not find path: $path" -ErrorAction Stop
        }

        $VHD = Get-FslDisk -path $Path

        try {
            ## Need to mount ##
            if ($vhd.attached) {
                $mount = get-disk | Where-Object {$_.Location -eq $Path}
            }
            else {
                $mount = Mount-DiskImage -ImagePath $Path -Passthru -ErrorAction Stop | get-diskimage
            }
        }
        catch {
            write-error $Error[0]
            Write-Error "Could not mount VHD. Perhaps the VHDs in use."
        }
        $driveLetter = $mount | Get-Disk | Get-Partition | Select-Object -ExpandProperty AccessPaths | Select-Object -first 1

        if ($driveLetter -like "*\\?\Volume{*" -or $null -eq $driveLetter) {
            Write-Warning "Drive Letter is already removed for $Path"
            exit
        }

        $DL = $Driveletter.substring(0, 1)

        try {
            $Volume = Get-Volume | where-Object {$_.DriveLetter -eq $DL}
        }
        catch {
            Write-Error $Error[0]
        }
        try {
            $Volume | Get-Partition | Remove-PartitionAccessPath -AccessPath $Driveletter
            Write-Verbose "$(Get-Date): Successfully removed $Driveletter"
        }
        catch {
            Write-Error $Error[0]
            exit
        }
            
        try {
            Dismount-DiskImage -ImagePath $Path
        }
        catch {
            Write-Error $Error[0]
        }
    }

    end {
    }
}