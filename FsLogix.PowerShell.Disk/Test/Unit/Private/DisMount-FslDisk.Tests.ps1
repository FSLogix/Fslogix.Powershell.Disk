$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    Mock 'Dismount-VHD' -MockWith {$true}
    it 'returns some verbose lines'{
        #-Verbose 4>&1 pipelines verbose 4 to 1
        $verboseLine = dismount-FslDisk -fullname "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd" -Verbose 4>&1
        $verboseLine.count | Should BeGreaterThan 0
    }
    it 'Assert the mock is called'{
        Assert-MockCalled -CommandName "dismount-vhd" -Times 1 -ParameterFilter {$path -eq "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd"}
    }

    Context -name 'Should not throw'{
        it 'Calling dismount-fsldisk without path'{
            {dismount-FslDisk} | should not throw
        }
    }
}