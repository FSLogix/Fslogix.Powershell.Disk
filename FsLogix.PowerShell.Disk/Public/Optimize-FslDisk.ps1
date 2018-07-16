function Optimize-FslDisk {
    <#
        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.string]$path,

        [Parameter(Position = 1, ValueFromPipeline = $true)]
        [Validateset('full', 'retrim', 'quick')]
        [System.String]$mode = 'quick',

        [Parameter(Position = 2)]
        [Switch]$Delete
    )

    begin {
        set-strictmode -Version latest
    }



    process {
        if (-not(test-path $path)) {
            Write-Error "Could not find path: $path"
        }
        else {
            $VHD = Get-FslDisk -path $path
        }
        if ($VHD.Vhdtype -eq 'fixed') {
            Write-Error "VHD cannot be of type: 'fixed'. Must be dynamic"
            exit
        }

        ## Remove Duplicates ##
        if ($Delete) {
            get-FslDuplicateFiles -path $path -csvpath 'test.csv' -Remove 'true'
        }## Removed Duplicates

        try {
            Write-Verbose "$(Get-Date): Optimizing VHD: $path"
            Optimize-VHD -Path $path -Mode $mode
        }
        catch {
            Write-Error $Error[0]
        }
    }

    end {
    }
}