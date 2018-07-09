$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"
Describe $sut {
    Context -name 'Does not throw' {
        It 'Does not throw' {
            {get-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (2).vhd'} | should not throw
        }
        It 'Does not throw' {
            {get-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (2).vhd' -remove} | should not throw
        }
    }
    Context -Name 'Warning Messages'{
        it 'No Vhds in path'{
            {get-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit\Public' } | out-null | should throw
        }
        it 'No Osts in VHD'{
            {get-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx'} | should throw
        }
    }
    Context -Name 'mock' {
    
        Mock -CommandName get-driveletter -MockWith {$true}
        mock -CommandName dismount-FslDisk -MockWith {$true}
        mock -CommandName get-fslvhd -MockWith {$true}
        mock -CommandName remove-item -MockWith {$true}

        it 'Should throw' {
            {Get-FslOstFile -path 'C:\blah'}  | should throw
        }

        it 'Asserts all verifiable mocks' {
            Assert-VerifiableMocks
        }
    }
    
}