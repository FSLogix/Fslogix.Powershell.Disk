function dismount-FslDisk {
    <#
        .SYNOPSIS
        Dismounts a VHD.

        .DESCRIPTION
        This function can be added to any script that requires dismounting
        a vhd.

        .PARAMETER VHDPath
        The target path for VHD location.

        .EXAMPLE
        dismount-FSLVHD -path \\server\share\ODFC\vhd1.vhdx
        Will dismount vhd1.vhdx
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("VHDPath")]
        [System.String]$FullName
    )
    
    begin {
        set-strictmode -version latest
    }#begin
    
    process {
        $name = split-path -Path $FullName -Leaf

        try {
            
            write-verbose "Dismounting $name"
            Dismount-VHD -Path $FullName -ErrorAction Stop
            Write-Verbose "Successfully dismounted $name"

        }
        catch {
            
            write-error $Error[0]
            exit
        }
    }#process

    end {
    }
}