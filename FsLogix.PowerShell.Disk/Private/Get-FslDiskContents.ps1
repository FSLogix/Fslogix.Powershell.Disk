function Get-FslDiskContents {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$VHDPath,

        [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true)]
        [System.String]$path
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {

        ## Helper functions get-fslvhd and get-fsldisk will help with errors ##
        $VHDs = get-fslVHD -path $VHDPath

        ## Get contents ##
        foreach($vhd in $VHDs){

            $name = split-path -path $vhd.path -leaf
            if($vhd.Attached){
                write-error "Vhd: $name is currently in use."
                break;
            }

            $DriveLetter = get-driveletter -path $vhd.path
            $FilePath = join-path ($DriveLetter)($path)
            get-childitem -Path $FilePath

            dismount-FslDisk -path $vhd.path
        }
        
    }
    
    end {
    }
}