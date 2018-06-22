function Get-FslDuplicates {
    <#
        .SYNOPSIS
        Returns any duplicate files within disk into a comma separated excel file.
        User can opt to have duplicate files removed.

    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, 
            Mandatory = $true, 
            ValueFromPipeline = $true,
            HelpMessage = 'Path to specified VHD or directory containing VHDs' )]
        [System.String]$vhdPath,

        [Parameter(Position = 1, 
            Mandatory = $false, 
            ValueFromPipeline = $true,
            HelpMessage = 'Specific directory search within a VHD')]
        [System.String]$Path,

        [Parameter(Position = 2, Mandatory = $true)]
        [System.String]$Csvpath = '$env:temp\test.csv',

        [Parameter(Position = 3, Mandatory = $false, ValueFromPipeline = $true)]
        [Alias("Confirm")]
        [ValidateSet("True", "False")]
        [System.String]$Remove_Duplicates = "false"
    )
    
    begin {
        set-strictmode -Version latest
        $Remove = $false
    }
    
    process {

        ## Validate inputs ##
        if ($Remove_Duplicates -eq "true") {
            $Remove -eq $true
        }

        if ($path -ne "") {
            $check_If_Directory = [System.IO.Path]::GetExtension($path)
            if ($check_If_Directory -ne "") {
                Write-Error "$Path must be a directory."
                exit
            }
        }

        $CheckCsv = [System.IO.Path]::GetExtension($csvpath)
        if ($CheckCsv -ne ".csv") {
            write-error "$Csvpath must have .csv extension"
            exit 
        }
        else {
            remove-item -path $Csvpath -Force -ErrorAction SilentlyContinue
            Add-Content -Path $Csvpath 'VHD,Original,Duplicate'
        }
        
        ## Get VHDs ##
        Write-Verbose "Retrieving VHD(s)"
        $VHDs = get-fslvhd -path $vhdpath
        if ($null -eq $VHDs) {
            Write-Warning "Could not find VHDs in $vhdpath"
            exit
        }
        
        ## Search Duplicates ##
        foreach ($vhd in $VHDs) {
            
            ## Get-Duplicate Helper function
            get-FslDuplicateFiles -path $vhd.path -folderpath $Path -csvpath $Csvpath -remove $Remove_Duplicates
        }
    }
    
    end {
    }
}