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
        $Dismount,

        [Switch]
        $Passthru
    )
    
    begin {
        Set-StrictMode -Version Latest
        #Requires -RunAsAdministrator
    }
    
    process {

        ## FsLogix VHD's default partition number is 1
        if(!$PSBoundParameters.ContainsKey("PartitionNumber")){
            $PartitionNumber = 1
        }

        $Driveletterassigned = $false
        $Letter = [int][char]'Z'
        $VHD = Get-FslDisk -Path $Path

        if ($Vhd.attached) {
            $Disk = Get-Disk -Number $VHD.Number
        }
        else {
            $Disk = Mount-DiskImage -ImagePath $path -NoDriveLetter -PassThru -ErrorAction Stop | Get-Diskimage
        }

        $DiskNumber = $Disk.Number

        Try{
            $Partition = Get-Partition -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -ErrorAction Stop
        }catch{
            Write-Error $Error[0]
        }
        
        while(!$Driveletterassigned){
            Try{
                $Partition | set-partition -NewDriveLetter $([char]$Letter) -ErrorAction Stop
                $Driveletterassigned = $true
            }catch{
                ## For some reason
                ## $Letter-- won't work.
                $letter = $letter - 1
                if ([char]$Letter -eq 'C') {
                    Write-Warning "Could not assign a drive letter. Is the partition number correct?"
                    Write-Error "Cannot find free drive letter." -ErrorAction Stop
                }
            }
        }
        if ($Driveletterassigned) {
            Write-Verbose "Assigned DriveLetter: $([char]$Letter):\."
        }

        if($Dismount){
            Try{
                Dismount-DiskImage -ImagePath $Path -ErrorAction Stop
            }catch{
                Write-Error $Error[0]
            }
        }

        if($Passthru){
            "$([char]$Letter):\"
        }
    }
    
    end {
    }
}