function dismount-FslDisk {
    <#
        .SYNOPSIS
        Dismounts a VHD or dismounts currently existing attached VHDs.

        .DESCRIPTION
        This function can be added to any script that requires dismounting
        a vhd.

        .PARAMETER VHDPath
        Optional target path for VHD location.

        .EXAMPLE
        dismount-FSLDisk -path \\server\share\ODFC\vhd1.vhdx
        Will dismount vhd1.vhdx

        .EXAMPLE
        dismount-fslDisk
        Will dismount all currently attached VHD's.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
        [Alias("Path")]
        [System.String]$FullName
    )
    
    begin {
        set-strictmode -version latest
    }#begin
    
    process {
        if ($FullName -ne "") {
            $name = split-path -Path $FullName -Leaf
            try {
                write-verbose "Dismounting $name"
                Dismount-VHD -Path $FullName -ErrorAction Stop
                Write-Verbose "Successfully dismounted $name"
            }catch {
                write-error $Error[0]
                exit
            }
        }else {
            
            Write-Verbose "Getting all currently attached disks..."
            $Get_Attached_VHDs = Get-Disk | select-object -Property Model, Location

            if($null -eq $Get_Attached_VHDs){
                Write-Warning "Could not find any attached VHD's. Exiting script..."
                Exit
            }else{
                Write-Verbose "Dismounting attached disks..."
                foreach($vhd in $Get_Attached_VHDs){
                    if($vhd.Model -like "Virtual Disk*"){
                        $name = split-path -path $vhd.location -Leaf
                        try{
                            Write-Verbose "Dismounting VHD: $name"
                            Dismount-VHD -path $vhd.location -ErrorAction Stop
                            Write-Verbose "Succesfully dismounted VHD: $name"
                        }catch{
                            Write-Error $Error[0]
                        }
                    }else{
                        Write-Warning "$($vhd.Model) is not a virtual disk. Skipping"
                    }
                }
            }
            Write-Verbose "Finishing script."
            
        }
    }#process

    end {
    }
}