function Get-FslProfiles {
    <#
        .SYNOPSIS
        Retrives all user profiles within a directory

        .TODO
        Flipflop regex match?
    #>
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
        #Example: 'Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811'
        [regex]$OriginalMatch = "^(.*?)_S-\d-\d+-(\d+-){1,14}\d+$"
        # Is this how the flip flop regex should be?
        #[regex]$FlipFlopMatch = "^S-\d-\d+-(\d+-){1,14}\d+(.*?)$"

        $Users = get-childitem -path $UserDirectory | Where-Object { $_.PSIsContainer } -ErrorAction Stop
        if($null -eq $Users){
            Write-Warning "Could not find any directories within $userDirectory"
            Exit
        }

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