#Requires -Modules "Hyper-V"
function Compress-FslDisk {
    [CmdletBinding(DefaultParameterSetName = "None")]
    param (
        [Parameter(Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][Alias("Path")]
        [System.String]$VHD,

        [Parameter(Position = 1,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "Index"
        )][Alias("Start")][int]$Starting_Index,

        [Parameter(Position = 2,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "Index"
        )][Alias("End")][int]$Ending_Index,

        [Parameter(Position = 3)]
        [Switch]$Dismount
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {
        $VHD_List = Get-FslVHD -path $VHD -start $Starting_Index -end $Ending_Index
        foreach ($_disk in $VHD_List) {
            $Disk_Info = [PSCustomObject]@{
                Name  = split-path -path $_disk.path -Leaf
                Path  = $_disk.path
                InUse = $_disk.attached
            }
           
            if ($Disk_Info.InUse) {
                if($Dismount){ 
                    Write-Warning "$(Get-Date): $($Disk_Info.name) is currently in use. Dismounting disk."
                    dismount-FslDisk -FullName $Disk_Info.Path
                }else{
                    Write-Error "$($Disk_Info.name) is currently in use. Please de-attach." -ErrorAction Stop
                }
            }

            Get-FslDuplicates -vhdpath $Disk_Info.Path -Remove
            
            Write-Verbose "$(Get-Date): Compacting Virtual Disk: $($Disk_Info.Name)"
            Optimize-VHD -Path $Disk_Info.path -Mode Full -ErrorAction Stop
            Write-Verbose "$(Get-Date): Successfully Compacted Virtual Disk: $($Disk_Info.Name)"
        }
        
    }
    
    end {
    }
}