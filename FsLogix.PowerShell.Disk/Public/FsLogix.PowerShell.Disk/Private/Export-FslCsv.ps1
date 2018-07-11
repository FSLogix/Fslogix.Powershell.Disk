function Export-FslCsv {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$CsvLocation,

        [Parameter(Position = 1)]
        [System.String]$Destination
    )

    begin {
        function Get-Delimiter($csv) {
            $excluded = ([Int][Char]'0'..[Int][Char]'9') + ([Int][Char]'A'..[Int][Char]'Z') + ([Int][Char]'a'..[Int][Char]'z') + 32
            $lines = get-content $csv | Select-Object -first 1

            $DelimiterHash = @{}
            [Bool]$Quotes = $false
            foreach($char in $lines.ToCharArray()){
                #Write-Verbose "$char"
                if(-not($quotes) -and $char -eq '"'){
                    $Quotes = $true
                    continue
                }
                if($Quotes -and $char -eq '"'){
                    $Quotes = $false
                    continue
                }
                if(-not($Quotes)){
                    if($excluded -notcontains $char){
                        $DelimiterHash.$([Char]$char) ++
                    }
                }
            }
            $Delimiter = $DelimiterHash.GetEnumerator() | Sort-Object -Property value -Descending | select-object -first 1
            return $Delimiter.key
        }
    }

    process {

        if ($Destination) {
            if (-not(test-path -path $Destination)) {
                Write-Error "Could not find directory: $Destination" -ErrorAction stop
            }
            if ((Get-Item $Destination) -isnot [System.IO.DirectoryInfo]) {
                Write-Error "Destination: $Destination must be a directory, not a file." -ErrorAction Stop
            }
        }

        if (test-path -path $CsvLocation) {
            $CSVFiles = Get-ChildItem -path $CsvLocation -recurse -Filter "*.csv"
        }
        else {
            Write-Error "Could not find directory $CsvLocation" -ErrorAction Stop
        }

        if ($null -eq $CSVFiles) {
            Write-Warning "Could not find any CSV files in $CsvLocation"
        }

        foreach ($csv in $CSVFiles) {
            $excel = New-Object -ComObject excel.application 
            $workbook = $excel.Workbooks.Add(1)
            $worksheet = $workbook.worksheets.Item(1)
            $delimiter = Get-Delimiter($csv.fullname)

            $TxtConnector = ("TEXT;" + $csv.fullname)
            $Connector = $worksheet.QueryTables.add($TxtConnector, $worksheet.Range("A1"))

            $query = $worksheet.QueryTables.item($Connector.name)
            $query.TextFileOtherDelimiter = "$delimiter"
            $query.TextFileParseType = 1
            $query.TextFileColumnDataTypes = , 1 * $worksheet.Cells.Columns.Count
            $query.AdjustColumnWidth = 1
            $query.Refresh() | Out-Null
            $query.Delete()


            if ($Destination -ne "") {
                $ExcelDestination = $Destination + "\" + [System.String]$csv.basename + ".xlsx"
            }
            else {
                $ExcelDestination = [System.String]$csv.directory + "\" + [System.String]$csv.basename + ".xlsx"
            }
            if (Test-Path -Path $ExcelDestination) {
                remove-item $ExcelDestination -Force
            }

            $Excel.ActiveWorkbook.SaveAs($ExcelDestination, 51)
            Write-Verbose "Sucessfully converted $($csv.name) to Excel format."
            $Excel.Quit()
        }
    }
    end {
    }
}
