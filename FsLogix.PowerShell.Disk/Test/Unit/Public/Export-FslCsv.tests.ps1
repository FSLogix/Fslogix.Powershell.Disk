$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"
$excel = New-Object -ComObject Excel.Application

Describe $sut {
    context -name 'should throw'{
        it 'Invalid destination'{
            {export-fslcsv -CsvLocation 'C:\Users\danie\Documents\VHDModuleProject\test.csv' -Destination 'C:\blah'} | should throw
        }
        it 'Destination path is a file'{
            {export-fslcsv -CsvLocation 'C:\Users\danie\Documents\VHDModuleProject\test.csv' -Destination 'C:\Users\danie\Documents\VHDModuleProject\test.xlsx'} | should throw
        }
        it 'csv path is invalid'{
            {export-fslcsv -CsvLocation 'C:\blah'} | should throw
        }
        it 'No csv files found in path should give warning'{
            export-fslcsv -CsvLocation 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Private' -WarningVariable warn
            $warn.count | should be 1
        }
    }
    context -name 'Should not throw'{
        BeforeEach{
            mock -CommandName test-path -MockWith{$true}
            Mock New-Object {$excel} -ParameterFilter { $ComObject -eq 'excel.Application' }
        }
        it 'Valid paths'{
            {Export-FslCsv -CsvLocation 'C:\Users\danie\Documents\VHDModuleProject\test.csv'} | should not throw
        }
        it 'Starting excel after conversion'{
            mock -CommandName Start-Process -MockWith{$true}
            {Export-FslCsv -CsvLocation 'C:\Users\danie\Documents\VHDModuleProject\test.csv' -open} | should not throw
        }
    }
    Context -name 'Delimiter Error'{
        mock get-fsldelimiter -MockWith {return $null}

        it 'Delimiter is null'{
            {Export-FslCsv -CsvLocation 'C:\Users\danie\Documents\VHDModuleProject\test.csv' -WarningAction Stop} | should throw
        }
    }
    context -name 'Mail'{
        {Export-FslCsv -CsvLocation 'C:\Users\danie\Documents\VHDModuleProject\test.csv' -email 'dkim@fslogix.com' -OutlookUsername 'Dkim@fslogix.com' -Password 'ullneverknow'} | should not throw
    }
}