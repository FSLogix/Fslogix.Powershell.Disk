function Dismount-FslDisk {
    [CmdletBinding(DefaultParameterSetName = "Path")]
    param (
        [Parameter( Position = 0,
                    Mandatory = $true,
                    ValueFromPipelineByPropertyName = $true,
                    ParameterSetName = "Path")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter( Position = 1,
                    Mandatory = $true,
                    ValueFromPipelineByPropertyName = $true,
                    ParameterSetName = "DiskNumber")]
        [ValidateNotNullOrEmpty()]
        [int]$DiskNumber
    )
    
    begin {
        Set-StrictMode -Version Latest
        #Requires -RunAsAdministrator
    }
    
    process {

        Switch ($PSCmdlet.ParameterSetName){
            Path {
                if(-not(test-path -path $Path)){
                    Write-Error "Could not find path: $Path." -ErrorAction Stop
                }
                $Disk = Get-Disk | Where-Object {$_.Location -eq $Path}
                if(!$Disk){
                    Write-Error "Could not find disk with path: $Path" -ErrorAction Stop
                }
                $DiskNumber = $Disk.Number
                $Partition = Get-Partition -DiskNumber $DiskNumber
            }
            DiskNumber {
                $Disk = Get-Disk -Number $DiskNumber
                if(!$Disk){
                    Write-Error "Could not find disk with number: $DiskNumber" -ErrorAction Stop
                }
                $Path = $disk.Location
                $Partition = Get-Partition -DiskNumber $DiskNumber
            }
        }

        $Has_JunctionPoint = $Partition | select-object -ExpandProperty AccessPaths | select-object -first 1
        if($Has_JunctionPoint -like "*C:\programdata\fslogix\Guid*"){
      
            Try{
                ## FsLogix's Default VHD partition number is set to 1
                Remove-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber 1 -AccessPath $Has_JunctionPoint -ErrorAction Stop
            }catch{
                ## If VHD was created through disk management/Hyper-V, default partition number is set to 2
                try{
                    Remove-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber 2 -AccessPath $Has_JunctionPoint -ErrorAction Stop
                }catch{
                    Write-Warning "Could not remove junction point."
                    Write-Error $Error[0]
                    exit
                }
            }

            Try{
                Remove-Item -Path $Has_JunctionPoint -Force -ErrorAction Stop
            }catch{
                Write-Error $Error[0]
            }

        }
        
        try{
            Dismount-DiskImage -ImagePath $Path -ErrorAction Stop
        }catch{
            Write-Warning "Could not dismount disk."
            Write-Error $Error[0]
        }
        
        
    }
    
    end {
    }
}