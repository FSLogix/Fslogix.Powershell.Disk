function Get-FslDisk {
    <#
        .SYNOPSIS
        Returns a VHD's properties and it's information/values.

        .DESCRIPTION
        If the VHD is mounted, more information is retrieved, however performance will be slower.
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

        $Extension = get-item -path $Path

        if($Extension.Extension -eq ".vhd" -or $Extension.Extension -eq ".vhdx" ){

            $name               = split-path -path $path -leaf
            $VHDInfo            = $Path | Get-DiskImage -ErrorAction Stop
            $Disk_Item_Info     = Get-item -path $path
            $extension          = ($Disk_Item_Info.Extension).TrimStart(".")
            $CreationTime       = $Disk_Item_Info.CreationTime
            $LastWriteTime      = $Disk_Item_Info.LastWriteTime
            $LastAccessTime     = $Disk_Item_Info.LastAccessTime
            $SizeGB             = $VHDInfo.Size / 1gb
            $SizeMB             = $VHDInfo.Size / 1mb
            $FreeSpace          = [Math]::Round((($VHDInfo.Size - $VHDInfo.FileSize) / 1gb) ,2)

            $DiskNumber         = $null
            $NumberOfPartitions = $null
            $Guid               = $null
            $VHDType            = $null

            if ($VHDInfo.Attached) {

                $Disk               = get-disk | where-object {$_.location -eq $path}
                $DiskNumber         = $Disk.number
                $NumberOfPartitions = $Disk.NumberOfPartitions
                $Guid               = $Disk.Guid -replace '{','' -replace '}',''
                $VHDType            = Get-FslDriveType -number $DiskNumber

            }

            <#$Properties = [PSCustomObject]@{
                ComputerName        = $env:COMPUTERNAME
                Name                = $name
                path                = $Path
                Guid                = $Guid
                VhdFormat           = $extension
                VHDType             = $VHDType
                Attached            = $VHDInfo.Attached
                DiskNumber          = $DiskNumber
                NumberOfPartitions  = $NumberOfPartitions
                CreationTime        = $CreationTime
                LastWriteTime       = $LastWriteTime
                LastAccessTime      = $LastAccessTime
                SizeInGB            = $SizeGB
                SizeInMB            = $SizeMB
                FreespaceGB         = $FreeSpace
            }

            Write-Output $Properties #>

            $VHDInfo | Add-Member @{ComputerName        = $env:COMPUTERNAME  }
            $VHDInfo | Add-Member @{Name                = $Name              }
            $VHDInfo | Add-Member @{path                = $Path              }
            $VHDInfo | Add-Member @{Guid                = $Guid              }
            $VHDInfo | Add-member @{VhdFormat           = $extension         }
            $VHDInfo | Add-Member @{VHDType             = $VHDType           }
            $VHDInfo | Add-Member @{DiskNumber          = $DiskNumber        }
            $VHDInfo | Add-Member @{NumberOfPartitions  = $NumberOfPartitions}
            $VHDInfo | Add-Member @{CreationTime        = $CreationTime      }
            $VHDInfo | Add-Member @{LastWriteTime       = $LastWriteTime     }
            $VHDInfo | Add-Member @{LastAccessTime      = $LastAccessTime    }
            $VHDInfo | Add-Member @{SizeInGB            = $SizeGB            }
            $VHDInfo | Add-Member @{SizeInMB            = $SizeMB            }
            $VHDInfo | Add-Member @{FreespaceGB         = $FreeSpace         }

            Write-Output $VHDInfo

        }
        else {
            Write-Error "File path should include a .vhd or .vhdx extension." -ErrorAction Stop
        }
    }
    end {
    }
}