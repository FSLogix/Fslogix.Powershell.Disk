function Get-FslDelimiter {
    <#
        .SYNOPSIS
        Returns the delimiter of a csv file

        .DESCRIPTION
        Created by Daniel Kim @ FsLogix
        https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER Csv
        Path to user specified csv file

        .EXAMPLE
        Get-FslDelimiter -csv 'C:\Users\danie\Documents\VHDModuleProject\test.csv'
        Returns the delimiter used in test.csv, which is a ','.
    #>
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [System.String]$csv
    )

    if ($csv -notlike "*.csv") {
        Write-Error "CSV file must include .csv extension" -ErrorAction Stop
    }

    if (-not(test-path -path $csv)) {
        Write-Error "Could not find path: $csv" -ErrorAction Stop
    }

    $excluded = ([Int][Char]'0'..[Int][Char]'9') + ([Int][Char]'A'..[Int][Char]'Z') + ([Int][Char]'a'..[Int][Char]'z') + 32
    $lines = get-content $csv | Select-Object -First 2

    $DelimiterHash = @{}
    [Bool]$Quotes = $false
    #"VHD","Folder","Original","Duplicate"
    #"test","C:\","hi.txt","hi2.txt"
    foreach ($char in $lines.ToCharArray()) {
        #Write-Verbose "$char"
        if (-not($quotes) -and $char -eq '"') {
            $Quotes = $true
            continue
        }
        if ($Quotes -and $char -eq '"') {
            $Quotes = $false
            continue
        }
        if (-not($Quotes)) {
            if ($excluded -notcontains $char) {
                $counter = 1
                if ($DelimiterHash.ContainsKey($char)) {
                    $DelimiterHash[$char]++
                }
                else {
                    $DelimiterHash.add($char, $counter)
                }
            }
        }
    }
    $Delimiter = $DelimiterHash.GetEnumerator() | Sort-Object -Property value -Descending | select-object -first 1
    Write-Output $Delimiter.Key
}