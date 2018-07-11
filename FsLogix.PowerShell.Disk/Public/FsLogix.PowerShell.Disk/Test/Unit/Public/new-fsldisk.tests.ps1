$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    Mock -CommandName New-VHD -MockWith {} -Verifiable
    Mock -CommandName Test-Path -MockWith { $false}
    Mock -CommandName Initialize-Disk -MockWith {$true}
    mock -CommandName New-Partition -MockWith {$true}
    mock -CommandName Format-Volume -MockWith {$true}
    mock -CommandName Test-FslVHD -MockWith {$true}

    it 'Should throw'{
        {New-FslDisk -NewVHDPath 'C:\blah'} | out-null | should throw
    }

    It 'Does not write Errors' {
        $errors = new-FslDisk -NewVHDPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test50.vhd' | out-null
        $errors.count | should Be 0
    }

    It 'Asserts all verifiable mocks' {
        Assert-VerifiableMocks
    }
}