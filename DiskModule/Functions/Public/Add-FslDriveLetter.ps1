function Add-FslDriveLetter {
    [CmdletBinding()]
    param (
        [Parameter( Position = 0,
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [System.String]
        $Path,

        [Parameter (Position = 1,
                    ValueFromPipelineByPropertyName = $true)]
        [int]
        $PartitionNumber,

        [Switch]
        $Dismount
    )
    
    begin {
        Set-StrictMode -Version Latest
        #Requires -RunAsAdministrator
    }
    
    process {
        $Driveletterassigned = $false
        $Letter = [int][char]'Z'
        $VHD = Get-FslDisk -Path $Path

        if ($Vhd.attached) {
            $Disk = Get-Disk -Number $VHD.Number
        }
        else {
            $Disk = Mount-DiskImage -ImagePath $path -NoDriveLetter -PassThru -ErrorAction Stop | Get-Diskimage
        }

        ## FsLogix VHD's default partition number is 1
        if(!$PartitionNumber){
            $PartitionNumber = 1
        }

        $DiskNumber = $Disk.Number
        $Partition = Get-Partition -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber
        
        while(!$Driveletterassigned){
            Try{
                $Partition | set-partition -NewDriveLetter $Letter -ErrorAction Stop
            }catch{
                ## For some reason
                    ## $Letter-- won't work.
                    $letter = $letter - 1
                    if ($Letter -eq 'C') {
                        Write-Error "Cannot find free drive letter" -ErrorAction Stop
                    }
            }
        }
        if ($Driveletterassigned) {
            Write-Verbose "Assigned DriveLetter: $([char]$letter)."
        }

        if($Dismount){
            Dismount-DiskImage -ImagePath $Path
        }
    }
    
    end {
    }
}