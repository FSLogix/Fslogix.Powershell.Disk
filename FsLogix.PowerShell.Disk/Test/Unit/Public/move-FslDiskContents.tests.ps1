$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    #NEED TO ADD MORE TEST CASES
    context -name 'Outputs that should throw'{
        it 'Invalid vhd path'{
            {move-fsldiskcontents -path "C:\blah" -Destination "C:\Users\Danie\Documents" -Overwrite "yes"} | out-null | should throw
        }
        it 'Invalid destination'{
            {move-fsldiskcontents -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.2.vhd" -Destination "C:\blah" -Overwrite "yes"} | out-null | should throw
        }
    }
}