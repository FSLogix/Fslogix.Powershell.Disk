function Copy-FslToDisk {
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
        [System.String[]]$Path,

        [Parameter( Position = 2,
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
        Try{
            $Mounted_Disk = Mount-FslDisk -Path $VHD -PassThru -ErrorAction Stop
        }Catch{
            Write-Error $Error[0]
            exit
        }
        $Mounted_Path       = $Mounted_Disk.Mount
        $Disk_Number        = $Mounted_Disk.disknumber
        
        $Copy_Destination = join-path ($Mounted_Path) ($Destination)
        Write-Verbose $Copy_Destination
        if(-not(test-path -path $Copy_Destination)){
            New-Item -ItemType Directory $Copy_Destination -Force -ErrorAction SilentlyContinue | Out-Null
        }
        Try{
            foreach($file in $Path){
                ## Using Robocopy to copy permissions.
                $Command = "robocopy $file $Copy_Destination /s /w:1 /r:1 /xj /sec /copyall"
                Invoke-Expression $Command | Out-Null
            }
        }catch{
            Dismount-fsldisk -DiskNumber $Disk_Number
            Write-Error $Error[0]
            exit
        }

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