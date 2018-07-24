function Get-FslFunctions {
    <#
        .SYNOPSIS
        Returns a list of public functions and their parameters.

        .PARAMETER Path
        If User wants to specify a function

        .EXAMPLE
        Get-FslFunctions
        Returns all public functions

        .EXAMPLE
        Get-FslFunctions -path 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Public\Get-FslFunctions.ps1'
        Returns the function name and parameter for this path.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.String]$path
    )

    begin {
        Set-strictmode -Version Latest
    }

    process {

        if ($path) {
            if (-not(test-path $path)) {
                Write-Error "Could not find path: $path" -ErrorAction Stop
            }
            if($path -notlike "*.ps1") {
                Write-Error "Path must be a powershell function." -ErrorAction Stop
            }
            else {
                $ParentPath = $path
            }
        }
        else { $ParentPath = $PSScriptRoot }

        $Type = split-path -path $ParentPath -leaf

        $Functions = get-childitem -path $ParentPath

        $output = @{}

        foreach ($func in $Functions) {
            $output.add($func.Basename, (GET-Command $func.Basename).parameters.Keys)
        }

        if ($path) {
            $label = "Function"
        }
        else {
            $label = "$type Functions"
        }

        $output = $output.GetEnumerator() | Select-Object @{Label = $label ; Expression = {$_.Key}}, @{Label = 'Parameters'; Expression = {$_.Value}}

        Write-Output $output
    }

    end {
    }
}