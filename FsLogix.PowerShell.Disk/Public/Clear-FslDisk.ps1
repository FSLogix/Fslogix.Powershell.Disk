function Clear-FslDisk {
    <#
        .SYNOPSIS
        Empties the contents of a disk

        .PARAMETER Path
        Path to an user specified disk or directory of disks

        .PARAMETER Folder
        Optional parameter to specified folder within a disk

        .PARAMETER Force
        Force deletion of disk contents, even if in use.

        .EXAMPLE
        Clear-fsldisk -path 'C:\test1.vhd'
        Clears out all the contents within test1.vhd

        .EXAMPLE
        Clear-fsldisk -path 'C:\test1.vhd' -folder 'public\tests'
        Clears out all the contents in the folder 'Public\tests' within the VHD test1.vhd

        .EXAMPLE
        Clear-fsldisk -path 'C:\vhds'
        Obtains all the VHD's within the directory 'C:\vhds' and clears their contents.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$path,

        [Parameter(Position = 1)]
        [System.String]$folder,

        [Parameter(Position = 2)]
        [Switch]$force
    )

    begin {
        set-strictmode -Version latest
    }

    process {
        if (-not(test-path $path)) {
            Write-Error "Could not find path: $Path" -ErrorAction Stop
        }

        ## Helper function ##
        $VHDs = get-fslvhd -path $path

        foreach ($vhd in $VHDs) {

            ## Helper function ##
            $contents = Get-fsldiskcontents -VHDPath $vhd.path -FolderPath $folder
            $folderpath = Join-Path (Split-Path $vhd.path -leaf) ($folder)

            if ($null -eq $contents) {
                Write-Warning "$folderpath is already cleared or empty."
                continue
            }else{ Write-Verbose "$(Get-Date): Retreived contents"}

            if ($force) {
                $contents | remove-item -Recurse -Force
            }else {
                $contents | remove-item -Recurse
            }

            Write-Verbose "$(Get-Date): Succesfully cleared $folderpath"
            dismount-FslDisk -path $vhd.path

        }#foreach
    }

    end {
    }
}
