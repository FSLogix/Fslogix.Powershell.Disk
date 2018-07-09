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
        dismount-fslDisk -dismountall
        Will dismount all currently attached VHD's.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Path")]
        [System.String]$FullName,

        # Parameter help description
        [Parameter(Position = 1,ValueFromPipelineByPropertyName = $true)]
        [Switch]$DismountAll
    )
    
    begin {
        set-strictmode -version latest
    }#begin
    
    process {
        if ($FullName -ne "") {
            $name = split-path -Path $FullName -Leaf
            try {
                Dismount-VHD -Path $FullName -ErrorAction Stop
                Write-Verbose "Successfully dismounted $name"
            }catch {
                write-error $Error[0]
                exit
            }
        }
        if($DismountAll){
            
            $Get_Attached_VHDs = Get-Disk | select-object -Property Model, Location

            if($null -eq $Get_Attached_VHDs){
                Write-Warning "Could not find any attached VHD's. Exiting script..."
                Exit
            }else{
                foreach($vhd in $Get_Attached_VHDs){
                    if($vhd.Model -like "Virtual Disk*"){
                        $name = split-path -path $vhd.location -Leaf
                        try{
                            Dismount-VHD -path $vhd.location -ErrorAction Stop
                            Write-Verbose "Succesfully dismounted VHD: $name"
                        }catch{
                            Write-Error $Error[0]
                        }
                    }else{
                        #Write-Warning "$($vhd.Model) is not a virtual disk. Skipping"
                    }
                }
            }
        }
    }#process

    end {
    }
}