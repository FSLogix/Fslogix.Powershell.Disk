function Get-FslDisk {
    <#
        .SYNOPSIS
        Returns a VHD's properties and it's information/values.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        Helper function for Get-FslVHD
        Obtains a single VHD.
        The script will return the respective VHD's properties and it's information/values.

        .PARAMETER path
        User specified path location to a VHD. Must include .vhd/.vhdx extension
        .EXAMPLE
        get-FslVHD -path C:\Users\Daniel\ODFC\test1.vhd
        Will return the properties associated with test1.vhdKs
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$Path
    )

    begin {
        set-strictmode -Version latest
    }

    process {

        if (-not(test-path -path $Path)) {
            Write-Error "Cannot find path: $path" -ErrorAction Stop
        }


        if ($path -like "*.vhd*") {

            $name = split-path -path $path -leaf
            $VHDInfo = $Path | Get-DiskImage -ErrorAction Stop
            $DiskNumber = $null
            $extension = ((get-item -path $Path).Extension).TrimStart(".")
            
            if ($VHDInfo.Attached) {
                $DiskNumber = ((get-disk).where( {$_.location -eq $path})).number
            }
        
        
            $VHDInfo | Add-Member @{path = $VHDInfo.ImagePath} 
            $VHDInfo | Add-member @{VhdFormat = $extension} 
            $VHDInfo | Add-Member @{DiskNumber = $DiskNumber} 
            $VHDInfo | Add-Member @{Name = $Name} 
          
            Write-Output $VHDInfo
            Dismount-DiskImage -ImagePath $Path
        }
        else {
            Write-Error "File path should include a .vhd or .vhdx extension." -ErrorAction Stop
        }
    }
    end {
    }
}