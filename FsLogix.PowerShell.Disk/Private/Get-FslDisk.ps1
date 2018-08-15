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

        .PARAMETER Full
        Switch parameter to obtain full information of a disk. Performance will be slower.

        .EXAMPLE
        get-FslVHD -path C:\Users\Daniel\ODFC\test1.vhd
        Will return the properties associated with test1.vhd's
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$Path,

        [Parameter(Position = 1)]
        [Switch]$Full
    )

    begin {
        set-strictmode -Version latest
        function Get-Ost($VHD_Path){
            $DriveLetter = get-driveletter -VHDPath $VHD_Path
            $Ost = get-childitem -path (join-path $DriveLetter *.ost) -recurse
            dismount-FslDisk -FullName $VHD_Path
            if ($null -eq $ost) {
                return 0
            }
            else {
                try {
                    $count = $ost.count
                }
                catch [System.Management.Automation.PropertyNotFoundException] {
                    # When calling the get-childitem cmdlet, if the cmldet only returns one
                    # object, then it loses the count property, despite working on terminal.
                    # When only one object is found, the type is System.IO.FileSystemInfo
                    # When objects found is greater than 1, the type is System.Array
                    $count = 1
                }
                return $count
            }
        }
    }

    process {

        if (-not(test-path -path $Path)) {
            Write-Error "Cannot find path: $path" -ErrorAction Stop
        }
        $Disk_Item_Info = get-item -path $Path
        if ($Disk_Item_Info.Extension -eq ".vhd" -or $Disk_Item_Info.Extension -eq ".vhdx" ) {
            try {
                $VHDInfo = $Path | Get-DiskImage -ErrorAction Stop
            }
            catch {
                Write-Error $Error[0]
            }
            $name               = split-path -path $path -leaf
            $extension          = ($Disk_Item_Info.Extension).TrimStart(".")
            $CreationTime       = $Disk_Item_Info.CreationTime
            $LastWriteTime      = $Disk_Item_Info.LastWriteTime
            $LastAccessTime     = $Disk_Item_Info.LastAccessTime
            $SizeGB             = $VHDInfo.Size / 1gb
            $SizeMB             = $VHDInfo.Size / 1mb
            $FreeSpace          = [Math]::Round((($VHDInfo.Size - $VHDInfo.FileSize) / 1gb) , 2)

            $DiskNumber         = $null
            $NumberOfPartitions = $null
            $Guid               = $null
            $VHDType            = $null
            
            if ($VHDInfo.Attached) {

                $Disk = get-disk | where-object {$_.location -eq $path}
                $DiskNumber         = $Disk.number
                $NumberOfPartitions = $Disk.NumberOfPartitions
                $Guid               = $Disk.Guid -replace '{', '' -replace '}', ''
                $VHDType            = Get-FslDriveType -number $DiskNumber

            }
            $VHDInfo | Add-Member @{ComputerName        = $env:COMPUTERNAME  }
            $VHDInfo | Add-Member @{Name                = $Name              }
            $VHDInfo | Add-Member @{path                = $Path              }
            $VHDInfo | Add-Member @{Guid                = $Guid              }
            $VHDInfo | Add-member @{VhdFormat           = $extension         }
            $VHDInfo | Add-Member @{VHDType             = $VHDType           }
            $VHDInfo | Add-Member @{DiskNumber          = $DiskNumber        }
            $VHDInfo | Add-Member @{NumberOfPartitions  = $NumberOfPartitions}

            if($full){

                $OstCount = Get-Ost($Path)

                $VHDInfo | Add-Member @{CreationTime        = $CreationTime      }
                $VHDInfo | Add-Member @{LastWriteTime       = $LastWriteTime     }
                $VHDInfo | Add-Member @{LastAccessTime      = $LastAccessTime    }
                $VHDInfo | Add-Member @{SizeInGB            = $SizeGB            }
                $VHDInfo | Add-Member @{SizeInMB            = $SizeMB            }
                $VHDInfo | Add-Member @{FreespaceGB         = $FreeSpace         }
                $VHDInfo | Add-Member @{OstCount            = $OstCount          }
            }
            Write-Output $VHDInfo

        }
        else {
            Write-Error "File path should include a .vhd or .vhdx extension." -ErrorAction Stop
        }
    }
    end {
    }
}