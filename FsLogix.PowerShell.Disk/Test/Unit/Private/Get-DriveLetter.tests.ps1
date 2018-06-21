$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {

    context -name 'Outputs that should throw'{

        Mock 'mount-vhd'{
            $null
        }

        it 'User entered wrong path'{
            $invalid = {get-driveletter -path "C:\blah"} | Out-Null
            $invalid | should throw
        }
        it 'Assert the mock is not called for wrong path'{
            Assert-MockCalled -CommandName "mount-vhd" -Times 0 -ParameterFilter {$path -eq "C:\blah"}
        }
    }
    Context -name 'Should not throw'{
        if(-not(test-path -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd")){
            new-fsldisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd"
        }
        it 'Run script with correct vhd path'{
            {get-driveletter -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd"} | should not throw
            dismount-vhd -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd"
        }
    }
}