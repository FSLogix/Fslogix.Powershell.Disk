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

        .PARAMETER Start
        Optional parameter to specify a starting index for selecting disks

        .PARAMETER End
        Optional parameter to specify an ending index for selecting disks.
        Start has to be initialized.

        .PARAMETER Dismount
        Optional switch parameter if user wants VHD dismounted upon script completion.

        .EXAMPLE
        Clear-fsldisk -path 'C:\test1.vhd'
        Clears out all the contents within test1.vhd

        .EXAMPLE
        Clear-fsldisk -path 'C:\test1.vhd' -folder 'public\tests'
        Clears out all the contents in the folder 'Public\tests' within the VHD test1.vhd

        .EXAMPLE
        Clear-fsldisk -path 'C:\vhds'
        Obtains all the VHD's within the directory 'C:\vhds' and clears their contents.

        .EXAMPLE
        Clear-FslDisk -path 'C:\Dir -start 1 -end 10
        Obtains the first 10 vhd's in within the directory 'C:\dir' and clears their contents.
    #>
    [CmdletBinding(DefaultParametersetName='None')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$path,

        [Parameter(Position = 1)]
        [System.String]$folder,

        [Parameter(Position = 2)]
        [Switch]$force,

        [Parameter(Position = 3,ParameterSetName = 'index', Mandatory = $true)]
        [int]$Start,

        [Parameter(Position = 4,ParameterSetName = 'index', Mandatory = $true)]
        [int]$End,

        [Parameter(Position = 5)]
        [Switch]$dismount
    )

    begin {
        set-strictmode -Version latest

        if(-not(test-path -Path $path)){
            Write-Error "Could not find path: $Path" -ErrorAction Stop
        }
    }

    process {
        
        ## Helper function
        ## Get-FslVHD will validate error handling
        $VHDs = get-fslvhd -path $path -start $Start -end $End

        foreach ($vhd in $VHDs) {

            ## Helper function 
            ## Get-FslDiskContents will validate error handling
            $contents = Get-fsldiskcontents -VHDPath $vhd.path -FolderPath $folder
            $folderpath = Join-Path (Split-Path $vhd.path -leaf) ($folder)

            if ($null -eq $contents) {
                Write-Warning "$folderpath is already cleared or empty."
                continue
            }else{ Write-Verbose "$(Get-Date): Retreived contents"}

            ## Using a forloop is faster than sending to pipeling in remove-item.
            ## Speed test done by Joshua King
            foreach($item in $contents){
                if($force){
                    remove-item $item.fullname -Force -Recurse 
                }else{
                    remove-item $item.fullname -Recurse 
                }
            }

            Write-Verbose "$(Get-Date): Succesfully cleared $folderpath"
            
            if($dismount){
                dismount-FslDisk -path $vhd.path
            }
        }#foreach
    }

    end {
    }
}
