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

            $name               = split-path -path $path -leaf
            $VHDInfo            = $Path | Get-DiskImage -ErrorAction Stop
            $Disk_Item_Info     = Get-item -path $path
            $extension          = ($Disk_Item_Info.Extension).TrimStart(".")
            $CreationTime       = $Disk_Item_Info.CreationTime
            $LastWriteTime      = $Disk_Item_Info.LastWriteTime
            $LastAccessTime     = $Disk_Item_Info.LastAccessTime

            $DiskNumber         = $null
            $NumberOfPartitions = $null
            $Guid               = $null
            $VHDType            = $null
            
            if ($VHDInfo.Attached) {
                $Disk               = (get-disk | where-object {$_.location -eq $path})
                $DiskNumber         = $Disk.number
                $NumberOfPartitions = $Disk.NumberOfPartitions
                $Guid               = $Disk.Guid
                $VHDType            = Get-FslDriveType -number $DiskNumber
            }

            $VHDInfo | Add-Member @{Name                = $Name             }
            $VHDInfo | Add-Member @{path                = $VHDInfo.ImagePath}
            $VHDInfo | Add-Member @{Guid                = $Guid             } 
            $VHDInfo | Add-member @{VhdFormat           = $extension        } 
            $VHDInfo | Add-Member @{VHDType             = $VHDType          }
            $VHDInfo | Add-Member @{DiskNumber          = $DiskNumber       }
            $VHDInfo | Add-Member @{NumberOfPartitions  = $NumberOfPartitions}
            $VHDInfo | Add-Member @{CreationTime        = $CreationTime     }
            $VHDInfo | Add-Member @{LastWriteTime       = $LastWriteTime    }
            $VHDInfo | Add-Member @{LastAccessTime      = $LastAccessTime   }
        
            Write-Output $VHDInfo
        }
        else {
            Write-Error "File path should include a .vhd or .vhdx extension." -ErrorAction Stop
        }
    }
    end {
    }
}