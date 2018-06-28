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

        get-fsldiskcontents C:\users\danie\ODFC\test1.vhd share\test
        returns all the contents in 'share\test' directory within test1.vhd
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$VHDPath,

        [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true)]
        [System.String]$path,

        [Parameter(Position = 2, Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet($false,$true)]
        [System.Boolean]$recurse = 0

    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {

        Write-Verbose "Obtaining VHDs"
        ## Helper functions get-fslvhd and get-fsldisk will help with errors ##
        $VHDs = get-fslVHD -path $VHDPath

        ## Get contents ##
        Write-Verbose "Obtaining items in VHD"
        foreach($vhd in $VHDs){

            ## Helper function get-driveletter will help with error handling ##
            $DriveLetter = get-driveletter -path $vhd.path
            $FilePath = join-path ($DriveLetter)($path)

            if(-not(test-path -path $FilePath)){
                write-error "Path: $filepath is invalid."
            }

            try{
                Write-Verbose "Getting child items"
                if($recurse){
                    $contents = get-childitem -Path $FilePath -Recurse
                }else{
                    $contents = get-childitem -Path $FilePath
                }
            }catch{
                Write-Error $Error[0]
            }
            
            if($null -eq $contents){
                Write-Warning "Could not find any contents."
            }
            Write-Output $contents

            $vhd.path | dismount-FslDisk
        }
    }
    
    end {
    }
}