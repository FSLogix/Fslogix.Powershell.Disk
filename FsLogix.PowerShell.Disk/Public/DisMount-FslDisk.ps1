function dismount-FslDisk {
    <#
        .SYNOPSIS
        Dismounts a VHD or dismounts all currently existing attached VHDs.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER VHDPath
        Optional target path for VHD location.

        .EXAMPLE
        dismount-FSLDisk -path \\server\share\ODFC\vhd1.vhdx
        Will dismount vhd1.vhdx

        .EXAMPLE
        dismount-fslDisk -dismountall
        Will dismount all currently attached VHD's.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Path")]
        [System.String]$FullName,

        # Parameter help description
        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [Switch]$DismountAll
    )

    begin {
        set-strictmode -version latest
    }#begin

    process {
        if ($FullName -ne "") {
            if($FullName -notlike "*.vhd*"){
                Write-Error "Disk must include .vhd/.vhdx extension." -ErrorAction Stop
            }
            $name = split-path -Path $FullName -Leaf
            try {
                Dismount-VHD -Path $FullName -ErrorAction Stop
                Write-Verbose "$(Get-Date): Successfully dismounted $name"
            }
            catch {
                write-error $Error[0]
                exit
            }
        }
        if ($DismountAll) {

            $Get_Attached_VHDs = Get-Disk | select-object -Property Model, Location
            $VHDs = $Get_Attached_VHDs | Where-Object {$_.Model -like "Virtual Disk*"}

            if ($null -eq $VHDs) {
                Write-Warning "Could not find any attached VHD's."
            }
            else {
                foreach ($vhd in $VHDs) {
                    $name = split-path -path $vhd.location -Leaf
                    try {
                        Dismount-VHD -path $vhd.location -ErrorAction Stop
                        Write-Verbose "$(Get-Date): Succesfully dismounted VHD: $name"
                    }
                    catch {
                        Write-Error $Error[0]
                    }

                }
            }
        }
    }#process

    end {
    }
}