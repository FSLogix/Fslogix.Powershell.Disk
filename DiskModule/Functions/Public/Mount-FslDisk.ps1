function Mount-FslDisk {
    <#
        
    #>

    param(
        [Parameter( Position = 0, 
                    Mandatory = $true, 
                    ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Path,
        
        [Parameter( Position = 2 )]
        [Switch]$PassThru

    )
    begin {
        Set-StrictMode -Version Latest
        #Requires -RunAsAdministrator
    }
    process {

        if(-not(test-path -path $Path)){
            Write-Error "Could not find path: $Path" -ErrorAction Stop
        }

        Try{
            $mount = Mount-DiskImage -ImagePath $Path -PassThru -ErrorAction Stop | Get-DiskImage -ErrorAction Stop
        }catch{
            Write-Error $Error[0]
            exit
        }

        $Name = split-path -path $Path -Leaf
        $DiskNumber = $mount.Number
        $PartitonNumber = 1
        $GuidPath = "C:\programdata\fslogix\Guid"

        Try{
            $DriveLetter = Get-Partition -DiskNumber $DiskNumber -ErrorAction Stop | Select-Object -ExpandProperty AccessPaths | select-object -first 1
        }catch{
            Dismount-DiskImage -ImagePath $Path -ErrorAction SilentlyContinue
            Write-Error $Error[0]
            exit
        }
        if (($null -eq $DriveLetter) -or ($driveLetter -like "*\\?\Volume{*")) {
            
            Write-Verbose "$(Get-Date): Did not receive valid driveletter: $Driveletter. Assigning temporary junction point."
            $Guid = (New-Guid).Guid
            $JunctionPath = Join-path ($GuidPath) ($Guid)

            if(test-path -path $JunctionPath){
                Remove-Item -path $JunctionPath -Force -ErrorAction SilentlyContinue
            }

            Try{
                New-Item -Path $JunctionPath -ItemType Directory -ErrorAction Stop | Out-Null
            }catch{
                Write-Warning "Could not create junction path."
                Remove-Item -path $JunctionPath -Force -ErrorAction SilentlyContinue
                Dismount-DiskImage -ImagePath $Path -ErrorAction SilentlyContinue
                Write-Error $Error[0]
                exit
            }
            
            Try{
                ## FsLogix's VHD main partition is 1
                Add-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber 1 -AccessPath $JunctionPath -ErrorAction Stop
            }catch{
                
                ## If the VHD was created through Microsoft (Disk Management, Hyper-V, ect), Main Partition is 2
                try{
                    Add-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber 2 -AccessPath $JunctionPath -ErrorAction Stop
                    $PartitonNumber = 2
                }catch{
                    Write-Warning "Could not remove Junction point."
                    Remove-Item -path $JunctionPath -Force -ErrorAction SilentlyContinue
                    Dismount-DiskImage -ImagePath $Path -ErrorAction SilentlyContinue
                    Write-Error $Error[0]
                    exit
                }
            }
            
            $DriveLetter = $JunctionPath
        }

        if($DriveLetter.Length -eq 3){
            Write-Verbose "$(Get-Date): $Name mounted on Drive Letter [$Driveletter]."
        }else{
            Write-Verbose "$(Get-Date): $Name mounted on Drive junction point [$DriveLetter]."
        }

        if($PassThru){
            $Output = [PSCustomObject]@{
                DiskNumber      = $DiskNumber
                Mount           = $DriveLetter
                PartitionNumber = $PartitonNumber
            }
            $Output
        }
    }
}