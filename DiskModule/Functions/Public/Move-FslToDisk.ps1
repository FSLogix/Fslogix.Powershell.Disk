function Move-FslToDisk {
    [CmdletBinding()]
    param (
        [Parameter( Position = 0,
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [System.String]$VHD,

        [Parameter( Position = 1,
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [System.String]$Path,

        [Parameter( Position = 2,
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [System.String]$Destination,

        [Parameter (Position = 3)]
        [Switch]$Dismount
    )
    
    begin {
        Set-StrictMode -Version Latest
        #Requires -RunAsAdministrator
    }
    
    process {
        if(-not(test-path -path $Path)){
            Write-Error "Could not find Path: $Path" -ErrorAction Stop
        }
        
        Try{
            $Mounted_Disk = Mount-FslDisk -Path $VHD -PassThru -ErrorAction Stop
        }catch{
            Write-Error $Error
            exit
        }

        $Mounted_Path = $Mounted_Disk.Mount
        $Disk_Number = $Mounted_Disk.disknumber
        $Copy_Destination = join-path ($Mounted_Path) ($Destination)
     
        Try{
            Move-item -Path $Path -Destination $Copy_Destination -Force -ErrorAction Stop
        }catch{
            Dismount-fsldisk -DiskNumber $Disk_Number
            Write-Error $Error[0]
            exit
        }

        Write-Verbose "Successfully moved $path to $Destination"

        if($Dismount){
            Try{
                Dismount-fsldisk -DiskNumber $Disk_Number
            }catch{
                Write-Error $Error[0]
            }
        }
    }
    
    end {
    }
}