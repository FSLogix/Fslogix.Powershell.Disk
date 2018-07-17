$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    Context -name 'should throw'{
        it 'CSV path does not have csv extension'{
            {Get-FslDelimiter -csv 'C:\blah'} | should throw
        }
        it 'CSV path does not exist'{
            {Get-FslDelimiter -csv 'C:\blah.csv'} | should throw
        }
    }
    context -name 'should not throw'{
        BeforeEach{
            mock -CommandName Get-Content -MockWith {'"VHD","Name","Size"'}
        }
        it 'should not throw'{
            {get-fsldelimiter -csv 'C:\Users\danie\Documents\VHDModuleProject\test.csv' } | should not throw
        }
        it 'output should be "," for {"VHD","Name","Size"}'{
            $output = Get-FslDelimiter -csv 'C:\Users\danie\Documents\VHDModuleProject\test.csv'
            $output | should be ','
        }

        it 'Output should be "." for {"VHD"."NAME"."SIZE"}'{
            mock -CommandName Get-Content -MockWith {'"VHD"."NAME"."SIZE"'}
            $output = Get-FslDelimiter -csv 'C:\Users\danie\Documents\VHDModuleProject\test.csv'
            $output | should be '.'
        }
    }
}