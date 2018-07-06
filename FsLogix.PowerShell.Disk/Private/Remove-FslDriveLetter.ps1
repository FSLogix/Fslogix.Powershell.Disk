function Remove-FslDriveLetter {
    [CmdletBinding()]
    <#
        .SYNOPSIS
        Removes a drive letter associated with a virtual disk.

        .PARAMETER Path
        Path to a either specified virtual disk or directory containing disks.

        .EXAMPLE
        Remove-FslDriveLetter -path C:\Users\danie\Documents\test\test1.vhd
        Removes the drive letter mapped to test1.vhd
    #>
    param (
        [Parameter(Position = 0, Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
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
        if(-not(test-path -path $path)){
            Write-Error "Could not find path: $path"
            exit
        }
        foreach ($vhd in $VHDs) {
            try {
                ## Need to mount ##
                if ($vhd.attached) {
                    $mount = get-disk | Where-Object {$_.Location -eq $vhd.path}
                }
                else {
                    $mount = Mount-VHD -path $vhd.path -Passthru -ErrorAction Stop
                }
            }
            catch {
                write-error $Error[0]
                Write-Error "Could not mount VHD. Perhaps the VHDs in use."
                break
            }
            $driveLetter = $mount | Get-Disk | Get-Partition | Select-Object -ExpandProperty AccessPaths | Select-Object -first 1
            
            if ($driveLetter -like "*\\?\Volume{*" -or $null -eq $driveLetter) {
                Write-Warning "Drive Letter is already removed for $($vhd.path)"
                break
            }

            $Driveletter = get-driveletter -VHDPath $vhd.path
            $DL = $Driveletter.substring(0, 1)
            
            try {
                $Volume = Get-Volume | where-Object {$_.DriveLetter -eq $DL}
            }
            catch {
                Write-Error $Error[0]
            }
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