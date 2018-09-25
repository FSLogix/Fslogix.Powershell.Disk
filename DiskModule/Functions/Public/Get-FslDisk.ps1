function Get-FslDisk {
    <#
        .SYNOPSIS
        Retrives a virtual disk's information.

        .DESCRIPTION
        Retrieves either a virtual disk's information or a collection
        of virtual disks within a folder.

        .PARAMETER Path
        Path to a specified Virtual disk

        .PARAMETER Folder
        Path to a specified directory containing virtual disks

        .EXAMPLE
        Get-FslDisk -path "C:\Tests\VHD\test.vhd"
        Retrives VHD: Test.vhd and returns informational output

        .EXAMPLE
        Get-FslDisk -folder "C:\tests\vhdFolder"
        Retrieves all the VHD's in folder: vhdFolder and returns their information.
    #>
    [CmdletBinding(DefaultParameterSetName = "Path")]
    param (
        [Parameter( Position = 0,
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    ParameterSetName = "Path")]
        [System.String]$Path,

        [Parameter( Position = 1,
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    ParameterSetName = "Folder")]
        [System.String]$Folder
    )
    
    begin {
        Set-StrictMode -Version Latest
        #Requires -RunAsAdministrator
        Function Get-DiskInformation{
            param(
                [Parameter (Position = 0,
                            Mandatory = $true,
                            ValueFromPipeline = $true,
                            ValueFromPipelineByPropertyName = $true)]
                [System.String]$VHDPath
            )

            $VHD        = Get-Diskimage -ImagePath $VHDPath
            $VHD_Item   = Get-Item -path $VHDPath

            $Format     = $VHD_Item.Extension.TrimStart('.')
            $Name       = split-path -path $VHDPath -Leaf
            $SizeGb     = $VHD.Size / 1gb
            $SizeMb     = $VHD.Size / 1mb
            $FreeSpace  = [Math]::Round((($VHD.Size - $VHD.FileSize) / 1gb) , 2)
            
            $VHD | Add-Member @{ ComputerName   = $Env:COMPUTERNAME}
            $VHD | Add-Member @{ Name           = $Name}
            $VHD | Add-Member @{ Format         = $Format}
            $VHD | Add-Member @{ SizeGb         = $SizeGb}
            $VHD | Add-Member @{ SizeMb         = $SizeMb}
            $VHD | Add-Member @{ FreeSpace      = $FreeSpace}

            Write-Output $VHD
        }
    }
    
    process {
        Switch ($PSCmdlet.ParameterSetName){
            Path {
                if(-not(test-path -path $Path)){
                    Write-Error "Could not find path: $Path" -ErrorAction Stop
                }
                $VHD_Info = Get-DiskInformation -VHDPath $Path
            }
            Folder {
                if( -not (test-path -path $Folder)){
                    Write-Error "Could not find directory: $Folder" -ErrorAction Stop
                }

                $VHDs_Info = Get-Childitem -path $Folder -Recurse -Filter "*.vhd*"
                $VHD_Info = foreach($Vhd in $VHDs_Info){
                    $VHD.FullName | Get-DiskInformation
                }
            }
        }
         Write-Output $VHD_Info
    }
    
    end {
    }
}