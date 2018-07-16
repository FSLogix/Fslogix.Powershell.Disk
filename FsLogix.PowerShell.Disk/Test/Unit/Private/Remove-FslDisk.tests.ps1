$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    BeforeAll{
        mock -CommandName Remove-item -MockWith {$true} -Verifiable
    }
    Context -name 'Should throw'{
        it 'Invalid path'{
            {Remove-fslDisk 'C:\blah'} | should throw
        }
    }
    Context -name 'Should not throw'{
        it 'Valid path'{
            {Remove-fsldisk 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' } | should not throw
        }
        it 'Valid directory path'{
            {Remove-fsldisk 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest'} | should not throw
        }
    }
    Context -name 'Remove fails'{
        mock -CommandName Remove-item -MockWith {throw $Error[0]}
        it 'fails'{
            {Remove-fsldisk 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -ErrorAction Stop } | should throw
        }
    }
}