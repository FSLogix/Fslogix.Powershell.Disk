$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    mock -CommandName get-FslDuplicateFiles -MockWith {$true}
    mock -CommandName optimize-vhd -MockWith {$true}

    it 'Invalid path should throw'{
        $invalid_cmd = {Optimize-FslDisk -path "C:\blah" -mode 'Quick'} | Out-Null
        $invalid_cmd | should throw
    }

    it 'Should Throw, using fixed vhd'{
        $invalid_cmd = {Optimize-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -mode 'quick'} | Out-Null
        $invalid_cmd | should throw 
    }

    it 'Assert mocks called'{
        Assert-VerifiableMocks
    }
}