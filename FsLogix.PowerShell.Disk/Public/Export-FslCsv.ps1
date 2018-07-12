function Export-FslCsv {
    <#
        .SYNOPSIS
        Converts a csv file into a delimited excel sheet

        .DESCRIPTION
        Created by Daniel Kim @ FsLogix
        https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER Csvlocation
        Location of the csv file

        .PARAMETER Destination
        Optional parameter to where the user would like the place the excel document.

        .PARAMETER Open
        If the user would like each converted csv file to open in excel.

        .EXAMPLE
        Export-FslCsv -csvlocation 'C:\Users\Danie\CSV\test.csv'
        Will convert the csv file, 'test.csv' into an excel document.

        .EXAMPLE
        Export-FslCsv -csvlocation 'C:\Users\Danie\CSV\Test.csv' -Destination 'C:\Users\Danie\XLSX'
        Will convert the csv file, 'test.csv' into an excel document and place them into the folder 'XLSX'

        .EXAMPLE
        Export-FslCsv -csvlocation 'C:\Users\Danie\CSV'
        Will convert ALL the csv files in directory, 'CSV', into excel documents.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$CsvLocation,

        [Parameter(Position = 1)]
        [System.String]$Destination,

        [Parameter(Position = 2)]
        [Switch]$open
    )

    begin {
        set-strictmode -Version latest
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

            ## Get-FslDelimiter helper function
            $delimiter = Get-FslDelimiter -csv $csv.fullname

            $Txt = ("TEXT;" + $csv.fullname)
            $QueryItems = $worksheet.QueryTables.add($Txt, $worksheet.Range("A1"))

            $query = $worksheet.QueryTables.item($QueryItems.name)
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

            $excel.quit()

            if($open){
                start-process -FilePath $ExcelDestination
            }
        }
    }
    end {
    }
}
