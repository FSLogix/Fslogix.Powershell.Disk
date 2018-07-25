function Get-FslProfiles {
    <#
        .SYNOPSIS
        Retrives all user profiles within a directory
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("path")]
        [System.String]$UserDirectory,

        [Parameter(Position = 1)]
        [regex]$OriginalMatch = "^(.*?)_S-\d-\d+-(\d+-){1,14}\d+$",

        [Parameter(Position = 2)]
        [regex]$FlipFlopMatch = "S-\d-\d+-(\d+-){1,14}\d+\.*?"
    )

    begin {
        set-strictmode -version latest
    }

    process {
        if (-not(test-path -path $UserDirectory)) {
            Write-Error "Could not find path: $UserDirectory" -ErrorAction Stop
        }

        $Users = get-childitem -path $UserDirectory | Where-Object { $_.PSIsContainer } -ErrorAction Stop
        if($null -eq $Users){
            Write-Warning "Could not find any directories within $userDirectory"
        }

        $UsersList = $users | Where-Object {($_.FullName -match $OriginalMatch) -or ($_.FullName -match $FlipFlopMatch)}
        if ($null -eq $UsersList) {
            Write-Warning "Could not find any users in $UserDirectory"
        }

        Write-Output $UsersList
    }
    end {
    }
}