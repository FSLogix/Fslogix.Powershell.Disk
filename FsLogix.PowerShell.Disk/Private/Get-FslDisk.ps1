function Get-FslDisk {
    <#
        .SYNOPSIS
        Returns a VHD's properties and it's information/values.

        .DESCRIPTION
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
            $name = split-path -path $path -leaf
            try {
                Write-Verbose "Obtaining VHD: $name's information"
                $VHDInfo = $Path | get-vhd
            }
            catch {
                Write-Error $Error[0]
                exit
            }
            Write-Output $VHDInfo
        }
        else { 
            Write-Error "File path should include a .vhd or .vhdx extension."
            exit
        }
    }
    end {
    }
}