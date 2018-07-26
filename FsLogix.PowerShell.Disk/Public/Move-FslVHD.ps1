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
        [ValidateSet("VHD", "VHDX")]
        [System.String]$VHDformat = "VHD", #Defaulted to .vhd

        [Parameter(Position = 3)]
        [ValidateSet("Dynamic", "Fixed")]
        [System.String]$VHDtype = "Dynamic", #Defaulted to dynamic

        [Parameter(Position = 4)]
        [Alias("Size")]
        [System.int64]$SizeInGB,

        [Parameter(Position = 5, ValuefromPipelineByPropertyName = $true, ValuefromPipeline = $true)]
        [regex]$OriginalMatch = "^(.*?)_S-\d-\d+-(\d+-){1,14}\d+$",

        [Parameter(Position = 6, ValuefromPipelineByPropertyName = $true, ValuefromPipeline = $true)]
        [regex]$FlipFlopMatch = "S-\d-\d+-(\d+-){1,14}\d+\.*?"

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
        $DestinationPath = get-item $Destination
        if (!$DestinationPath.PSIsContainer) {
            Write-Error "Destination must be a directory." -ErrorAction Stop
        }

        $VHDs = Get-FslVHD  -path $VHD -ErrorAction Stop
        foreach ($disk in $VHDs) {
            $name = split-path -path $disk.path -leaf

            if ($VHDformat -eq 'vhdx') {
                $name += 'x'
            }

            $Old_VHD_MigratedName = [System.IO.Path]::GetFileNameWithoutExtension($disk.path)
            $Old_VHD_MigratedName_Extension = [System.IO.Path]::GetExtension($disk.path)
            $OLD_VHD_New_MigratedName = $Old_VHD_MigratedName.replace('.', "-MIGRATED-")
            if ($OLD_VHD_New_MigratedName -eq $Old_VHD_MigratedName) {
                if ($OLD_VHD_New_MigratedName[0] -ne 'S') {
                    $OLD_VHD_New_MigratedName = "-MIGRATED-$OLD_VHD_New_MigratedName"
                }
                else {
                    $OLD_VHD_New_MigratedName += "-MIGRATED-"
                }
            }
            $OLD_VHD_New_MigratedName += $Old_VHD_MigratedName_Extension

            $Migrated_VHD = (split-path $Disk.path) + "\" + $OLD_VHD_New_MigratedName

            Write-Verbose "Renaming old VHD: $(split-path $disk.path -Leaf) to $Old_VHD_NEW_MigratedName"
            Rename-Item -Path $disk.path -NewName $OLD_VHD_New_MigratedName -ErrorAction Stop

            Write-Verbose "Creating New FslDisk at $Destination\$Name"
            New-FslDisk -NewVHDPath $Destination -name $Name -SizeInGB $SizeInGB -Type $VHDtype -overwrite

            Write-Verbose "Copying contents from $Migrated_VHD to $($Destination + "\" + $Name)"
            Copy-FslDiskToDisk -FirstVHDPath $Migrated_VHD -SecondVHDPath $($Destination + "\" + $Name) -Overwrite

        }#vhd
    }#process

    end {
    }
}