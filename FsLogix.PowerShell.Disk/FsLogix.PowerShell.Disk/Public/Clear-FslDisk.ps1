function Clear-FslDisk {
    <#
        .SYNOPSIS
        Empties the contents of a disk

        .PARAMETER Path
        Path to an user specified disk or directory of disks

        .PARAMETER Folder
        Optional parameter to specified folder within a disk

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
        [System.String]$folder
    )

    begin {
        set-strictmode -Version latest
    }

    process {
        if(-not(test-path $path)){
            Write-Error "Could not find path: $Path" -ErrorAction Stop
        }

        ## Helper function ##
        $VHDs = get-fslvhd -path $path

        foreach($vhd in $VHDs){

            ## Helper function ##
            $contents = Get-fsldiskcontents -VHDPath $vhd.path
            Write-Verbose "$(Get-Date): Retreived contents"
            if($null -eq $contents){
                Write-Warning "$(split-path $vhd.path -leaf) is already cleared."
                continue
            }

            try{
                $contents | remove-item -Recurse
            }catch{
                Write-Error $Error[0]
            }

            Write-Verbose "$(Get-Date): Succesfully cleared $(split-path $vhd.path -leaf)"
            dismount-FslDisk -path $vhd.path

        }#foreach
    }

    end {
    }
}
