function Get-FslFunctions {
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