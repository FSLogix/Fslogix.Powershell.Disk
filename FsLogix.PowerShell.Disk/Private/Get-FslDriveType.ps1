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
        
        #Write-Verbose "$((get-date).ToString('yy/mm/dd/hh:mm:ss:fff'))"
        $Disk = get-disk | where-object {$_.Number -eq $DiskNumber}

        # This line of code is really slow
        $Partition_AccessPaths = ($Disk | Get-Partition).AccessPaths
        #Write-Verbose "$((get-date).ToString('yy/mm/dd/hh:mm:ss:fff'))"
        
        $volume = Get-WMIObject -Class Win32_Volume
        foreach($AccessPath in $Partition_AccessPaths){
            if($volume.DeviceId -contains $AccessPath){
                $Volume = $volume | where-object {$_.deviceid -eq $Accesspath}
            }
        }
        #Write-Verbose "$((get-date).ToString('yy/mm/dd/hh:mm:ss:fff'))"
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