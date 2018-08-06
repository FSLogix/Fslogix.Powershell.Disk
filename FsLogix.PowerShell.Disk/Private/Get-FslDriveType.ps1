function Get-FslDriveType {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][alias("number")][int]$DiskNumber       
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {
    
        $Partition_AccessPaths = Get-Partition -DiskNumber 1 | select-object -expandproperty accesspaths | select-object -first 1
       
        $volume = Get-WMIObject -Class Win32_Volume | Where-Object {$_.DeviceId -eq $Partition_AccessPaths}
        
        if($null -eq $Volume){
            Write-Warning "Could not find volume associated with disk number: $DiskNumber"
        }else{
            $DriveType = $Volume.Drivetype
            switch($DriveType){
                0 {write-output "Unknown"   }
                1 {write-output "Removeable"}
                2 {write-output "Fixed"     }
                3 {write-output "Network"   }
                4 {write-output "CD-ROM"    }
                5 {write-output "RAM Disk"  }
            }
        }
    }
    
    end {
    }
}