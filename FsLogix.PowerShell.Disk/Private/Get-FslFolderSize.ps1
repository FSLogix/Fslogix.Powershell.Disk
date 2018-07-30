function Get-FslFolderSize {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Path,

        [Parameter(Position = 1)]
        [Switch]$gb
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {
        if (-not(test-path -path $path)) {
            Write-Error "Could not find path: $Path" -ErrorAction Stop
        }

        [System.double]$FolderSize = 0

        $Files = get-childitem -path $Path -Recurse
        foreach ($item in $Files) {
            try {
                $FolderSize += $item.Length
            }
            catch [System.Management.Automation.PropertyNotFoundException] {
                continue
            }
        }
        if ($gb) {
            $Size = [Math]::Round($FolderSize / 1gb)
        }
        else {
            $Size = [Math]::Round($FolderSize / 1mb)
        }
        
        Write-Output $Size
    }
    
    end {
    }
}