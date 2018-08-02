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
       
        $Disk = get-disk | where-object {$_.Number -eq $DiskNumber}
        $Partition_AccessPaths = $Disk | Get-Partition | Select-Object -expandproperty accesspaths
        $Volume = Get-Volume
        $Volume_UniqueID = $Volume.UniqueId
    
        foreach($AccessPath in $Partition_AccessPaths){
            if($Volume_UniqueID -contains $AccessPath){
                $Volume = $Volume | where-object {$_.uniqueid -eq $Accesspath}
            }
        }
        
        if($null -eq $Volume){
            Write-Warning "Could not find volume associated with disk number: $DiskNumber"
        }else{
            $DriveType = $volume.DriveType
            Write-Output $DriveType
        }
    }
    
    end {
    }
}