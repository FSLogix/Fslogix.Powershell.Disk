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
            if(-not(test-path -path $FullName)){
                Write-Error "Could not find path: $FullName" -ErrorAction Stop
            }else{
                $VHDInfo = get-item -Path $FullName
                $VHDExtension = $VHDInfo.Extension
                $Name = $VHDInfo.BaseName
            }
    
            if(($VHDExtension -eq '.vhd') -or ($VHDExtension -eq '.vhdx')){
                ## User entered valid vhd path
                try {
                    Dismount-DiskImage -ImagePath $FullName
                    Write-Verbose "$(Get-Date): Successfully dismounted $name"
                }
                catch {
                    write-error $Error[0]
                }
            
            }elseif (($null -eq $VHDExtension) -or ($VHDExtension -eq "")) {
                if($VHDInfo.Attributes -eq 'Directory'){
                    Write-Error "Path must be a VHD, not a directory." -ErrorAction Stop
                }else{
                    Write-Error "Could not find extension. Please validate path." -ErrorAction Stop
                }
            }else{
                Write-Error "Path must be a virtual disk." -ErrorAction Stop
            }
        }
        if ($DismountAll) {

            $Get_Attached_VHDs = Get-Disk | select-object -Property Model, Location
            $VHDs = $Get_Attached_VHDs | where-object {$_.Model -like "Virtual Disk*"}
           
            if ($null -eq $VHDs) {
                Write-Warning "Could not find any attached VHD's."
            }
            else {
                foreach ($vhd in $VHDs) {
                    $name = split-path -path $vhd.location -Leaf

                    Dismount-DiskImage -ImagePath $vhd.location -ErrorAction Stop
                    Write-Verbose "$(Get-Date): Succesfully dismounted VHD: $name"


                }
            }
        }
    }#process

    end {
    }
}