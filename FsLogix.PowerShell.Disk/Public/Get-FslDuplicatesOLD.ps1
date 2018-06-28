function Get-FslDuplicatesOLD {
    <#
        .SYNOPSIS
        Returns any duplicate files within disk into a comma separated excel file.
        User can opt to have duplicate files removed.

        .PARAMETER vhdPath
        Path to a specified VHD or directory containing VHD's.

        .PARAMETER path
        Optional path within a VHD.

        .PARAMETER CsvPath
        User specified destination for csv file output. Must have .csv extension.

        .PARAMETER Remove_Duplicates
        Optional parameter if user wants to remove the duplicates.

        .EXAMPLE
        get-fslduplicates -vhdpath C:\Users\danie\Documents\ODFC -csvpath $env:temp\test.csv
        Script will retrieve all VHD's in C:\Users\Danie\Documents\ODFC and search for duplicates.
        The duplicate files data will then be exported to a csv file located in the user's temp folder.

        .EXAMPLE
        get-fslduplicates -vhdpath C:\Users\danie\documents\ODFC -path Daniel\kim\ -csvpath $env:temp\test.csv
        Script will retrieve all VHDs and serach for duplicates in the 'Daniel\Kim\' directory within the VHD.

        .EXAMPLE
        get-fslduplicates -vhdpath C:\Users\danie\documents\ODFC -csvpath $env:temp\test.csv -confirm true
        Script will retrieve all VHD's and search for duplicates. The duplicate files data will be exported to 
        a csv file and then the script will remove all the duplicates.
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

        [Parameter(Position = 2,
            Mandatory = $false,
            HelpMessage = 'CSV output file detailing duplicate files')]
        [System.String]$Csvpath,

        [Parameter(Position = 3, Mandatory = $false, ValueFromPipeline = $true)]
        [Alias("Confirm")]
        [ValidateSet("True", "False")]
        [System.String]$Remove_Duplicates = "false"
    )
    
    begin {
        ## Helper function to validate requirements
        Get-Requirements
    
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

        if($Csvpath -ne ""){
            remove-item -path $Csvpath -Force -ErrorAction SilentlyContinue
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