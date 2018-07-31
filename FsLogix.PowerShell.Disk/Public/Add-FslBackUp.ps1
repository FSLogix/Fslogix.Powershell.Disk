function Add-FslBackUp {
    <#
        .SYNOPSIS
        Creates a backup of your files/Directories into a virtual hard disk.

        .DESCRIPTION
        The virtual disk created is defaulted with a name of: BACKUP-(Date).
        The virtual disk's size is defaulted to a vhdx, dynamic, and the size of the directory + 5gb.
        The user can opt in to change these values through parameters.
        Read more in the examples and Parameter information.

        .PARAMETER VHDName
        Optional parameter if User wants to specify the new disk's name.
        Otherwise defaulted to: BACKUP-(DATE)

        .PARAMETER Destination
        Optional Parameter if user wants to specify a destination for the new disk.
        OTherwise defaulted to the user's desktop.

        .PARAMETER SizeInGB
        Optional Parameter if user wants to specify a size for the new disk.
        Otherwise defaulted to 10gb.

        .PARAMETER Directory
        An array of directories the user inputs. These directories will be copied
        and backed up to the new disk.
        Either enter an array of directories, or simply input directories when prompted.

        .PARAMETER VHD
        Optional switch parameter if user wants new disk to be of .vhd format.
        Defaulted to .vhdx.

        .PARAMETER VHDx
        Optional switch parameter if user wants new dis kto be of .vhdx format.

        .EXAMPLE
        Add-FslBackUp
        Will create a new VHDx onto the user's desktop with the name 'BACKUP-(7-27-2018)'
        and copy over the contents of the user's directory and appdata.

        .EXAMPLE
        Add-FslBackup -Directory "C:\users\daniel\test"
        Will create a new VHDx onto the user's desktop with the name 'BACKUP-(7-27-2018)' and copy
        the contents of directory 'test' into that VHD.

        .EXAMPLE
        Add-FslBackup -Directory "C:\users\daniel\test" -Destination "C:\users\Daniel\backup"
        Will create a new VHDx into the backup folder with the name 'BACKUP-(7-27-2018)' and copy
        the contents of directory 'test' into that VHD.

        .EXAMPLE
        Add-FslBackup -Directory "C:\users\daniel\test" -VHDName 'Test'
        Will create a new VHDx onto the user's desktop with the name 'test' and copy
        the contents of directory 'test' into that VHD.

         .EXAMPLE
        Add-FslBackup -Directory "C:\users\daniel\test" -VHDName 'Test' -sizeInGb 5
        Will create a new VHDx onto the user's desktop with the name 'test' and copy
        the contents of directory 'test' into that VHD. The size of the VHD will be
        5 gb.

        .EXAMPLE
        Add-FslBackup -Directory "C:\users\daniel\test" -vhd
        Will create a new VHD onto the user's desktop with the name 'BACKUP-(7-27-2018)' and copy
        the contents of directory 'test' into that VHD.

    #>

    [CmdletBinding()]
    param (
        [Parameter(Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][System.String]$VHDName,

        [Parameter(Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][System.String]$Destination,

        [Parameter(Position = 2,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][Alias("Size")][System.Int64]$SizeInGB,

        [Parameter(Position = 3,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][System.String[]]$Directory,

        [Parameter(Position = 4,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][Switch]$VHD,

        [Parameter(Position = 5,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][Switch]$VHDx
    )

    begin {
        set-strictmode -Version latest
        $ValidDirectory = @()
        $TotalDirSize = 0
    }

    process {

        if ($VHDName.Contains(".vhd") -or $VHDName.Contains(".vhdx")) {
            $VHDName = [io.path]::GetFileNameWithoutExtension($VHDName)
        }

        ## If User did not specify VHD Name ##
        if ([System.String]::IsNullOrEmpty($VHDName)) {
            $VHDName = "BACKUP-$([datetime]::Today.ToString('yyyy-MM-dd'))"
        }

        ## If User did not specify Destination ##
        if ([System.String]::IsNullOrEmpty($Destination)) {
            $Destination = [Environment]::GetFolderPath("Desktop")
        }

        ## If user did not specify a directory
        if ([System.String]::IsNullOrEmpty($Directory)) {
            $Directory = @()
            $Directory += $env:APPDATA
            #$Romaings = split-path $env:APPDATA -Leaf
            $Directory += $env:USERPROFILE
            #$User = split-path $env:USERPROFILE -Leaf
        }
        foreach ($dir in $Directory) {
            if (-not(test-path $dir)) {
                Write-Error "Could not find directory path: $dir" -ErrorAction Continue
            }
            else {
                $ValidDirectory += $dir
                $TotalDirSize += Get-FslFolderSize -Path $dir -gb
            }
        }
        if ($SizeInGB -eq 0) {
            $SizeInGB = ($TotalDirSize + 5) * 1gb
        }
        
        ## User specified they want vhd ##
        if ($VHD) {
            $VHDName += ".vhd"
        }
        ## User specified they want vhdx
        if ($VHDx) {
            $VHDName += ".vhdx"
        }

        ## User specified neither, defauled to vhdx
        if ((-not($VHD)) -and (-not($VHDx))) {
            $VHDName += ".vhdx"
        }

        if (test-path $Destination) {
            New-FslDisk -NewVHDPath $Destination -Name $VHDName -SizeInGB $SizeInGB -overwrite
        }
        else {
            Write-Error "Could not find destination: $Destination" -ErrorAction Stop
        }

        $New_VHD_Path = $Destination + "\" + $VHDName
        foreach ($dir in $ValidDirectory) {
            
            Write-Verbose "Backing up directory: $dir"
            $Destination = split-path $dir -Leaf
            try {
                copy-FslToDisk -VhdPath $New_VHD_Path -FilePath $dir -Destination $Destination -recurse -Overwrite
            }
            catch {
                Write-Error "Could not back up directory: $dir" -ErrorAction Continue
            }
            
        }
    }

    end {
    }
}