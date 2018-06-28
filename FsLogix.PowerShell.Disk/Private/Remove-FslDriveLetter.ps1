function Remove-FslDriveLetter {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$Path
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {
        $VHDs = Get-FslVHD -path $Path
        if ($null -eq $VHDs) {
            Write-Warning "Could not find VHD's in $path"
            exit
        }
        foreach ($vhd in $VHDs) {
            try {
                ## Need to mount ##
                $mount = Mount-VHD -path $vhd.path -Passthru -ErrorAction Stop
                Write-Verbose "VHD succesfully mounted."
            }
            catch {
                write-error $Error[0]
                Write-Error "Could not mount VHD. Perhaps the VHD Path."
                break
            }
            $driveLetter = $mount | Get-Disk | Get-Partition | Select-Object -ExpandProperty AccessPaths | Select-Object -first 1
            
            if ($driveLetter -like "*\\?\Volume{*" -or $null -eq $driveLetter) {
                Write-Warning "Drive Letter is already removed for $($vhd.path)"
                break
            }

            $Driveletter = get-driveletter -VHDPath $vhd.path
            $DL = $Driveletter.substring(0, 1)
            $Volume = Get-Volume | where-Object {$_.DriveLetter -eq $DL}
            try {
                $Volume | Get-Partition | Remove-PartitionAccessPath -AccessPath $Driveletter
                Write-Verbose "Successfully removed $Driveletter"
            }
            catch {
                Write-Error $Error[0]
                exit
            }
            dismount-FslDisk -path $vhd.path
        }
        
        
    }
    
    end {
    }
}