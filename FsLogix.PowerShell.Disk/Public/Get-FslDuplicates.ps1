function Get-FslDuplicates {
    <#
        .SYNOPSIS
        Returns any duplicate files within disk into a comma separated excel file.
        User can opt to have duplicate files removed.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER vhdPath
        Path to a specified VHD or directory containing VHD's.

        .PARAMETER path
        Optional path within a VHD.

        .PARAMETER CsvPath
        User specified destination for csv file output. Must have .csv extension.
        User does not have to create csvfile, it will automatically be generated.

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
        get-fslduplicates -vhdpath C:\Users\danie\documents\ODFC -csvpath $env:temp\test.csv -confirm
        Script will retrieve all VHD's and search for duplicates. The duplicate files data will be exported to
        a csv file and then the script will remove all the duplicates.
    #>
    [CmdletBinding(DefaultParametersetName='None')]
    param (
        [Parameter(Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Path to specified VHD or directory containing VHDs' )]
        [System.String]$vhdPath,

        [Parameter(Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Specific directory search within a VHD')]
        [System.String]$Path,

        [Parameter(Position = 2,
            HelpMessage = 'CSV output file detailing duplicate files')]
        [System.String]$Csvpath,

        [Parameter(Position = 3)]
        [Alias("Confirm")]
        [switch]$Remove,

        [Parameter(Position = 4,ParameterSetName = 'index', Mandatory = $true)]
        [int]$Start,

        [Parameter(Position = 5,ParameterSetName = 'index', Mandatory = $true)]
        [int]$End
    )

    begin {

        if (![System.string]::IsNullOrEmpty($path)) {
            $check_If_Directory = [System.IO.Path]::GetExtension($path)
            if (![System.string]::IsNullOrEmpty($check_If_Directory)) {
                Write-Error "$Path must be a directory." -ErrorAction Stop
            }
        }

        if (![System.string]::IsNullOrEmpty($Csvpath)) {
            remove-item -path $Csvpath -Force -ErrorAction SilentlyContinue
        }

    }#Begin

    process {

        set-strictmode -Version latest
        ## Get VHDs ##
        Write-Verbose "$(Get-Date): Retrieving VHD(s)"
        $VHDs = get-fslvhd -path $vhdpath -start $start -end $end

        ## Search Duplicates ##
        foreach ($vhd in $VHDs) {
            if ($Remove) {
                get-FslDuplicateFiles -path $vhd.path -folderpath $Path -csvpath $Csvpath -Remove
            }
            else {
                get-FslDuplicateFiles -path $vhd.path -folderpath $Path -csvpath $Csvpath
            }
        }
    }#process

    end {

    }
}