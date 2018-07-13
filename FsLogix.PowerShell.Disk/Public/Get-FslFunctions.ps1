function Get-FslFunctions {
    <#
        .SYNOPSIS
        Returns list of public/private functions.
        Script defaulted to public functions

        .PARAMETER Private
        User can opt to return private functions

        .EXAMPLE
        Get-FslFunctions
        Returns all public functions

        .EXAMPLE
        Get-FslFunctions -private
        Returns all private functions
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [switch]$Private
    )

    begin {
        Set-strictmode -Version Latest
    }

    process {

        $ParentPath = $PSScriptRoot

        if($Private){ $ParentPath = $ParentPath.Replace("Public", "Private") }

        $Functions = get-childitem -path $ParentPath
        $output = @{}

        foreach($path in $Functions){
            $output.add($path.Basename, $path.Basename)
        }

        Write-Output $output
    }

    end {
    }
}