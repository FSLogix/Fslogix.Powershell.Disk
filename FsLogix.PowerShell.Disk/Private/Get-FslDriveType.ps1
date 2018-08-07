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
    
        $Partition = get-partition -disknumber $DiskNumber | Where-Object {$_.type -eq 'Basic'}
        $Partition_AccessPaths = $Partition | select-object -expandproperty accesspaths | select-object -first 1
        ## If Guid returned
        if($Partition_AccessPaths -like 'C:\ProgramData\FsLogix\FslGuid\*'){
            $Partition_AccessPaths = $Partition.Guid 
            $volume = Get-WMIObject -Class Win32_Volume | Where-Object {$_.DeviceId -eq "\\?\Volume$($Partition_AccessPaths)\"}
        }

        ## If driveletter returned
        if($Partition_AccessPaths.length -eq '3'){
            $volume = Get-WmiObject -class Win32_Volume | Where-Object {$_.Driveletter -eq "$($Partition_AccessPaths.substring(0,2))"}
        }

        ## If \\?\Volume{*}\ Returned
        if($Partition_AccessPaths -like "\\?\Volume{*}\"){
            $volume = Get-WMIObject -Class Win32_Volume | Where-Object {$_.DeviceId -eq $Partition_AccessPaths}
        }
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