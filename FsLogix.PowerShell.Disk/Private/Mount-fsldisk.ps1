function Mount-FslDisk {
    <#
        .SYNOPSIS
        Mounts either a VHD or a directory of VHD's

        .PARAMETER Path
        Path to a VHD or a directory of VHD's

        .PARAMETER MountAll
        Option to mount all the VHD's within a directory

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

            if($VHD_Count -gt $Max_Mount_Count){

                Write-Warning "The max number of virtual disks that can be mounted is $Max_Mount_Count"
                Write-Warning "Only Mounting $Max_Mount_Count out of $VHD_Count Disk's."

            }

            foreach($vhd in $VHDs){
                get-driveletter -VHDPath $vhd.path
                if($count++ -eq $Max_Mount_Count){
                    break
                }
            }
        }
        else {
            try{
                mount-vhd -path $path
                Write-Verbose "Sucessfully mounted: $path"
            }catch{
                Write-Error $Error[0]
            }
        }
    }

    end {
    }
}