$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    Mock 'mount-vhd' -MockWith {} -Verifiable
    Mock 'get-disk' -MockWith {$true}
    context -name 'Outputs that should throw'{

        it 'User entered wrong path'{
            $invalid = {get-driveletter -path "C:\blah"}
            $invalid | should throw
        }
        it 'Assert the mock is not called for wrong path'{
            Assert-MockCalled -CommandName "mount-vhd" -Times 0 -ParameterFilter {$path -eq "C:\blah"}
        }
    }
    Context -name 'Should not throw'{
        if(-not(test-path -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx")){
            new-fsldisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx"
        }
        it 'Run script with correct vhd path'{
            {get-driveletter -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx"} | should not throw
        }
    }
}