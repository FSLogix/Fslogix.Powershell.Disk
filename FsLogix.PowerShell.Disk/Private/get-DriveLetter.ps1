function get-driveletter {
    <#
        .NOTES
        Created on 6/6/18
        Created by Daniel Kim @ FSLogix    
        Created by Jim Moyle @ FSLogix
        .SYNOPSIS
        Obtains a virtual disk and returns the Drive Letter associated with it.
        If either Drive Letter is null or invalid, the script will assign the
        next available drive letter.
        .DESCRIPTION
        This function can be added to any script that requires mounting 
        a vhd and accessing it's contents.
        .PARAMETER VHDPath
        The target path for VHD location.
        .EXAMPLE
        mount-FSLVHD -path \\server\share\ODFC\vhd1.vhdx
        Will return the drive letter
    #>

    param(
        [Parameter(Position = 0, Mandatory = $true)][Alias("path")]
        [string]$VHDPath
    )
    begin {
        Set-StrictMode -Version Latest
    }
    process {
    
        $Attached = $false

        Write-Verbose "Validating path: $VHDPath"
        if (test-path $VHDPath) {
            Write-Verbose "$VHDPath is valid."
        }else {
            Write-Error "$VHDPath is invalid."
            exit
        }

        ## Helper function ##
        $VHDProperties = get-fsldisk -path $VHDPath

        if ($VHDProperties.Attached -eq $true) { $Attached = $true }

        if ($Attached) {
            ## If disk is already mounted, can skip mounting process. ##
            $mount = Get-Disk | Where-Object {$_.Location -eq $VHDPath}
        }else {
            try {
                ## Need to mount ##
                $mount = Mount-VHD -path $VHDPath -Passthru -ErrorAction Stop
                Write-Verbose "VHD succesfully mounted."
            }
            catch {
                write-error $Error[0]
                break
            }
        }
        $driveLetter = $mount | Get-Disk | Get-Partition | Select-Object -ExpandProperty AccessPaths | Select-Object -first 1
        
        ## This bug usually occurs because the Driveletter associated with the disk is already in use. ##
        if ($null -eq $driveLetter) {
            try {
                $disk = Get-Disk | Where-Object {$_.Location -eq $VHDPath}
                $disk | set-disk -IsOffline $false
            }
            catch {
                Write-Error $Error[0]
            }
            $driveLetter = $disk | Get-Partition | Select-Object -ExpandProperty AccessPaths | Select-Object -first 1
        }
        
        ## A drive letter was never initialized to the VHD ##
        if ($driveLetter -like "*\\?\Volume{*") {

            Write-warning "Driveletter is invalid: $Driveletter. Reassigning Drive Letter."
            
            
            
            if ($Attached) {
                $disk = Get-Disk | Where-Object {$_.Location -eq $VHDPath}
                $driveLetter = $disk | Get-Partition | Add-PartitionAccessPath -AssignDriveLetter
            }
            else {
                $driveLetter = $mount | get-disk | Get-Partition | Add-PartitionAccessPath -AssignDriveLetter | out-null
            }
            if ($null -eq $driveLetter) {

                ## If the VHD is mounted, then the assigned driver letter won't be updated.
                ## Have to dismount and remount for the drive letter to be updated.
                ## Perhaps there is a way to prevent this and speed the script up.

                ## Update 1 Tried using 'Update-disk', the function will then return wrong drive letter

                try {
                    Write-Verbose "Remounting VHD."
                    Dismount-VHD $VHDPath -ErrorAction Stop 
                }
                catch {
                    Write-Error $Error[0]
                    Write-Error "Failed to Dismount $VHDPath vhd will need to be manually dismounted"
                }
                try {
                    mount-vhd -path $VHDPath -ErrorAction stop
                    Write-Verbose "Remounted VHD"
                }
                catch {
                    Write-Error "Could not remount VHD"
                    exit
                }
            
            }#end if(null) 
            remove-variable -Name driveletter -ErrorAction SilentlyContinue
            remove-variable -Name mount -ErrorAction SilentlyContinue
            $disk = Get-Disk | Where-Object {$_.Location -eq $VHDPath}
            $driveLetter = $disk | Get-Partition | Select-Object -ExpandProperty AccessPaths | Select-Object -first 1
        }#end if {volume}
        else {
            Write-Verbose "VHD mounted on drive letter [$DriveLetter]"
        }#end else

        Write-Verbose "Outputting $driveletter"
        Write-Output $driveLetter
        #return $driveLetter
    }#end process
    end {
    }
}