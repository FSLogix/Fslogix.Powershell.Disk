function Mount-FslDisk {
    <#
        .SYNOPSIS
        Mounts either a VHD or a directory of VHD's

        .PARAMETER Path
        Path to a VHD or a directory of VHD's

        .PARAMETER MountAll
        Option to mount all the VHD's within a directory

        .EXAMPLE
        Mount-FslDisk 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
        Mounts the virtual disk testvhd1.vhd

        .EXAMPLE
        Mount-FslDisk 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2' -mountall
        Will mount all the VHD's within the directory, ODFCTest2.

    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [System.String]$Path,

        [Parameter(Position = 1)]
        [switch]$MountAll
    )

    begin {
        set-strictmode -Version latest
    }

    process {
        if ($MountAll) {

            $AvailableLetters = Get-FslAvailableDriveLetter
            $Max_Mount_Count = $AvailableLetters.count

            $VHDs = Get-FslVHD -path $Path
            $VHD_Count = $VHDs.count

            $Count = 0

            if ($VHD_Count -gt $Max_Mount_Count) {

                Write-Warning "The max number of virtual disks that can be mounted is $Max_Mount_Count"
                Write-Warning "Only Mounting $Max_Mount_Count out of $VHD_Count Disk's."

            }

            foreach ($vhd in $VHDs) {
                if ($vhd.attached) {
                    Write-Warning "$(split-path $vhd.path -leaf) is already mounted."
                }
                else {
                    try {
                        mount-vhd -path $vhd.path
                        Write-Verbose "Succesfully mounted $(split-path $vhd.path -leaf)."
                    }
                    catch {
                        Write-Error "Failed to mount $(split-path $vhd.path -leaf). Will need to be manually mounted."
                    }
                    if ($count++ -eq $Max_Mount_Count) {
                        break
                    }
                }
            }
        }
        else {
            try {
                mount-vhd -path $path
                Write-Verbose "$(Get-Date): Sucessfully mounted: $path"
            }
            catch {
                Write-Error $Error[0]
            }
        }
    }

    end {
    }
}