function Resize-FslPartition {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][Alias("Path")][System.String]$VHDpath,

        [Parameter(Position = 1,
            Mandatory = $true
        )][Alias("Size")][int]$SizeInGb,

        [Parameter(Position = 2)]
        [int]$PartitionNumber
    )
    
    begin {
        set-strictmode -version latest
    }
    
    process {
        if (-not(test-path -path $VHDpath)) {
            Write-Error "Could not validate path: $VhdPath." -ErrorAction Stop
        }
        else { $VHD = Get-FslVhd -path $VHDpath }

        foreach ($Current_Disk in $VHD) {
            
            $DriveLetter = Get-Driveletter $Current_Disk.path

            Write-Verbose "$($Current_disk.path)"
            Write-Verbose "$((Get-Disk).location)"
            $Disk = Get-Disk | Where-Object {$_.Location -eq $Current_Disk.path}
            $DiskNumber = $Disk.Number

            $Partition = Get-Partition -DiskNumber $DiskNumber
            if (!$PartitionNumber) {
                foreach ($part in $Partition) {
                    if ($part.DriveLetter -eq $DriveLetter.Substring(0, 1)) {
                        $PartitionNumber = $part.PartitionNumber
                    }
                }
            }
            else {
                if ($PartitionNumber -notin $Partition.PartitionNumber) {
                    Write-Error "Partition Number: $PartitionNumber does not exist." -ErrorAction Stop
                }
            }

            $error.Clear()
            Resize-Partition -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -Size ($SizeInGb * 1gb)
        
            if(!$error){
                Write-Verbose "Successfully resized $(split-path -path $Current_disk.path -leaf) to: $SizeInGb(gb)"
            }
        }
    }
    
    end {
    }
}