function Move-FslVhd {
    <#
        .SYNOPSIS
        Migrates the contents of an existing VHD to a new one.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [System.String]$VHD,

        [Parameter(Position = 1, Mandatory = $true)]
        [System.String]$Destination,

        [Parameter(Position = 2)]
        [System.String]$NewName,

        [Parameter(Position = 3)]
        [ValidateSet("VHD", "VHDX")]
        [System.String]$VHDformat = "VHD", #Defaulted to .vhd

        [Parameter(Position = 4)]
        [ValidateSet("Dynamic", "Fixed")]
        [System.String]$VHDtype = "Dynamic", #Defaulted to dynamic

        [Parameter(Position = 5)]
        [Alias("Size")]
        [System.int64]$SizeInGB,

        [Parameter(Position = 6, ValuefromPipelineByPropertyName = $true, ValuefromPipeline = $true)]
        [regex]$OriginalMatch = "^(.*?)_S-\d-\d+-(\d+-){1,14}\d+$"
    )

    begin {
        set-strictmode -Version latest
    }

    process {

        if (-not (test-path -path $VHD)) {
            Write-Error "Could not find VHD path: $VHD" -ErrorAction Stop
        }
        if (-not (test-path -path $Destination)) {
            Write-Warning "Could not find Destination directory. Make sure you are using a directory."
            Write-Error "Could not find destination directory: $Destination" -ErrorAction Stop
        }
        $DiskPath = get-item $VHD
        $DestinationPath = get-item $Destination
        if ($DiskPath.PSIsContainer) {
            Write-Error "Path: $VHD must be a virtual disk. Not a directory." -ErrorAction Stop
        }
        if(!$DestinationPath.PSIsContainer){
            Write-Error "Destination must be a directory." -ErrorAction Stop
        }

        else {
            $VHD | get-vhd -ErrorAction Stop | out-null
        }

        $name = split-path -path $VHD -leaf

        if($VHDformat -eq 'vhdx'){
            $name += 'x'
        }
        if ($NewName) {
            if($NewName -match $OriginalMatch){
                $Migrated_VHD = "$Destination\$NewName.$VHDformat"
            }else{
                Write-Error "$NewName does not match regex." -ErrorAction Stop
            }
        }else {
            $Migrated_VHD = "$Destination\$name"
        }

        New-FslDisk -NewVHDPath $Migrated_VHD -SizeInGB $SizeInGB -Type $VHDtype -overwrite

        Copy-FslDiskToDisk -FirstVHDPath $VHD -SecondVHDPath $Migrated_VHD -Overwrite
    }

    end {
    }
}