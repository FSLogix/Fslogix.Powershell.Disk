$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {

    BeforeAll {
        Mock -CommandName remove-item -MockWith {$true} -Verifiable
        Mock -CommandName get-fsldiskcontents -MockWith {'test'}
    }
    context -name 'Should throw' {
        it 'Invalid path'{
            {Clear-fsldisk -path "C:\blah"} | should throw
        }
        it 'Already cleared should give warning'{
            mock -CommandName get-fsldiskcontents -MockWith {$null}
            Clear-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd' -WarningVariable warn
            $warn.count | should be 1
        }
    }
    context -name 'Should not throw'{
        it 'Valid path'{
            {Clear-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'} | should not throw
        }
    }
}

