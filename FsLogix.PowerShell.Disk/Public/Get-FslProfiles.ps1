function Get-FslProfiles {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("path")]
        [System.String]$UserDirectory
    )

    begin {
        set-strictmode -version latest
    }

    process {
        if (-not(test-path -path $UserDirectory)) {
            Write-Error "Could not find path: $UserDirectory"
        }
        [regex]$OriginalMatch = "^(.*?)_S-\d-\d+-(\d+-){1,14}\d+$"

        $Users = get-childitem -path $UserDirectory | Where-Object { $_.PSIsContainer } -ErrorAction Stop
        $UsersList = $users | Where-Object {$_.FullName -match $OriginalMatch}

        if ($null -eq $UsersList) {
            Write-Warning "Could not find any users in $UserDirectory"
            exit
        }

        Write-Output $UsersList
    }
    end {
    }
}