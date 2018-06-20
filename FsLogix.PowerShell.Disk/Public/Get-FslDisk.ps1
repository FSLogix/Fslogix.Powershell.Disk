function Get-FslDisk {
    <#
        .SYNOPSIS
        Returns a VHD's properties and it's information/values.

        .DESCRIPTION
        Obtains a single VHD or multiple VHD's based on User's path.
        The script will return the respective VHD's properties and it's information/values.

        .PARAMETER path
        User specified path location to a VHD or a folder containing VHD's.
        If user wants specific VHD, path must include .vhd extension.

        .EXAMPLE
        get-FslVHD -path C:\Users\Daniel\ODFC\test1.vhd
        Will return the properties associated with test1.vhd

        .EXAMPLE
        get-fslVHD -path C:\Users\Daniel\ODFC\
        Will return the properties associated with all the VHD's
        within this path.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$Path
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {

        Write-Verbose "Confirming path..."
        if (test-path -path $Path) {
            write-verbose "Path confirmed."
        }
        else {
            write-error $error[0]
            exit
        }

        Write-Verbose "Confirming Extension..."
        if ($path -like "*.vhd*") {
            write-verbose "Extension confirmed..."
            try {
                Write-Verbose "Obtaining VHD information"
                $VHDInfo = $Path | get-vhd -ErrorAction SilentlyContinue
            }
            catch {
                Write-Error $Error[0]
                exit
            }
            Write-Output $VHDInfo
        }
        else { #User did a folder, get all VHD's
            Write-Error "File path should include a .vhd or .vhdx extension."
        }
    }
    end {
    }
}