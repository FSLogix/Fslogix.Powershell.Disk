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
    [CmdletBinding(DefaultParametersetName='None')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$CsvLocation,

        [Parameter(Position = 1)]
        [System.String]$Destination,

        [Parameter(Position = 2)]
        [Switch]$open,

        [Parameter(Position = 3, ParameterSetName = 'mail', Mandatory = $true)]
        [System.String]$email,

        [Parameter(Position = 4, ParameterSetName = 'mail', Mandatory = $true)]
        [System.String]$Username,

        [Parameter(Position = 5, ParameterSetName = 'mail', Mandatory = $true)]
        [Security.SecureString]$Password
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

            Write-Verbose "$(Get-Date): Creating excel document for csv file: $($csv.name)"
            $excel = New-Object -ComObject excel.application
            if ($null -eq $excel) {
                Write-Warning "Could not create excel document. You may have to repair excel installation."
                exit
            }

            $workbook = $excel.Workbooks.Add(1)
            $worksheet = $workbook.worksheets.Item(1)

            ## Get-FslDelimiter helper function
            $delimiter = Get-FslDelimiter -csv $csv.fullname
            if ($null -eq $delimiter) {
                Write-Warning "Could not retrieve delimiter. You may entered an incorrectly formatted csv file."
                exit
            }

            $Txt = ("TEXT;" + $csv.fullname)
            $QueryItems = $worksheet.QueryTables.add($Txt, $worksheet.Range("A1"))

            $query = $worksheet.QueryTables.item($QueryItems.name)
            $query.TextFileOtherDelimiter = "$delimiter"
            $query.TextFileParseType = 1
            $query.TextFileColumnDataTypes = , 1 * $worksheet.Cells.Columns.Count
            $query.AdjustColumnWidth = 1
            $query.Refresh() | Out-Null
            $query.Delete()


            if (![System.String]::IsNullOrEmpty($Destination)) {
                $ExcelDestination = $Destination + "\" + [System.String]$csv.basename + ".xlsx"
            }
            else {
                $ExcelDestination = [System.String]$csv.directory + "\" + [System.String]$csv.basename + ".xlsx"
            }
            if (Test-Path -Path $ExcelDestination) {
                remove-item $ExcelDestination -Force
            }

            $Excel.ActiveWorkbook.SaveAs($ExcelDestination, 51)
            Write-Verbose "$(Get-Date): Sucessfully converted $($csv.name) to Excel format."

            $Excel.Workbooks.close()
            $excel.quit()

            if (![System.String]::IsNullOrEmpty($email)) {

                $mail = new-object Net.Mail.MailMessage
                $mail.from = "Automated@Fslogix.com"
                $mail.To.Add($email)

                $mail.Subject = "FsLogix's xlsx document"
                $attachment = New-Object Net.Mail.Attachment($ExcelDestination)
                $mail.Attachments.add($attachment)

                $smtp = new-object Net.Mail.SmtpClient("smtp-mail.outlook.com", "587")
                $smtp.EnableSSL = $true;
                $smtp.Credentials = New-Object System.Net.NetworkCredential($Username,$Password);

                try {
                    $smtp.send($mail)
                    Write-Verbose "Mail sent to: $email"
                }
                catch {
                    Write-Error $Error[0]
                }
                $attachment.Dispose()
            }

            if ($open) {
                start-process -FilePath $ExcelDestination
            }
        }
    }
    end {
    }
}
