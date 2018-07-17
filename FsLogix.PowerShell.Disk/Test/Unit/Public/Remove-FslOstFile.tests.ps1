$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"
Describe $sut {
    BeforeAll{
        mock -CommandName get-fslostfile -MockWith {} -Verifiable
    }
        it 'Invalid path should throw'{
            {Remove-fslostfile -path 'C:\blah'} | should throw
        }
        it 'valid path should not throw'{
            {remove-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'} | should not throw
        }
        it 'valid path should not throw'{
            {remove-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd' -full} | should not throw
        }
}