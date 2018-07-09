function Get-FslDiskContents {
    <#
        .SYNOPSIS
        Get's the contents of a VHD.

        .DESCRIPTION
        User can either get contents of a VHD, or get contents in a specified path in a VHD.

        .PARAMETER VHDPath
        Path to the VHD. Cannot be a folder, must be a VHD and include .vhd/.vhdx extension.

        .PARAMETER path
        An optional folder path within the VHD

        .EXAMPLE
        get-fsldiskcontents C:\users\danie\ODFC\test1.vhd
        returns all the folders in test1.vhd

        .EXAMPLE
        get-fsldiskcontents C:\users\danie\ODFC\test1.vhd share\test
        returns all the contents in 'share\test' directory within test1.vhd

        .EXAMPLE
        get-fsldiskcontents C:\users\danie\ODFC\test1.vhd share\test -recurrse
        returns all the contents in 'share\test' directory within test1.vhd and all it's subdirectories/files.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$VHDPath,

        [Parameter(Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$FolderPath,

        [Parameter(Position = 2)]
        [Switch]$recurse
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {
        
        if(-not(test-path -path $VHDPath)){
            Write-Error "Could not find path: $VHDPath" -ErrorAction Stop
        }

        ## Helper functions get-fslvhd and get-fsldisk will help with errors ##
        $VHDs = get-fslVHD -path $VHDPath

        ## Get contents ##
        foreach ($vhd in $VHDs) {

            ## Helper function get-driveletter will help with error handling ##
            $DriveLetter = get-driveletter -path $vhd.path
            $FilePath = join-path ($DriveLetter)($Folderpath)

            if (-not(test-path -path $FilePath)) {
                write-error "Path: $filepath is invalid." -ErrorAction Stop
            }

            if ($recurse) {
                $contents = get-childitem -Path $FilePath -Recurse
            }
            else {
                $contents = get-childitem -Path $FilePath
            }
           
            if ($null -eq $contents) {
                Write-Warning "Could not find any contents."
            }
            Write-Output $contents

            $vhd.path | dismount-FslDisk
        }
    }
    
    end {
    }
}