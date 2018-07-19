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

        if($path){
            $ParentPath = $path
        }else{ $ParentPath = $PSScriptRoot }

        if($null -eq $ParentPath){
            Write-Error "Could not find path: $ParentPath" -ErrorAction Stop
        }

        $Type = split-path -path $ParentPath -leaf

        $Functions = get-childitem -path $ParentPath

        if($null -eq $Functions){
            Write-Warning "Could not find any functions within: $ParentPath"
            exit
        }

        $output = @{}

        foreach($func in $Functions){
            $output.add($func.Basename, (GET-Command $func.Basename).parameters.Keys)
        }

        if($path){
            $label = "Function"
        }else{
            $label = "$type Functions"
        }

        $output = $output.GetEnumerator() | Select-Object @{Label=$label ;Expression={$_.Key}},@{Label='Parameters';Expression={$_.Value}}

        Write-Output $output
    }

    end {
    }
}