$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    Mock -CommandName Remove-item -MockWith {$true}
    Mock -CommandName get-fslvhd -MockWith {} -Verifiable
    Context -Name "Should throw"{
        it 'Incorrect VHD path'{
            $command = {get-fsldiskinfo -path 'C:\blah'} | Out-Null
            $command | should throw
        }
        it 'Incorrect Csv path'{
            $command = {get-fsldiskinfo -csvfile 'C:\blah'} | Out-Null
            $command | should throw
        }
        it 'If incorrect csv path, remove-item should not be called' {
            Assert-MockCalled -CommandName "remove-item" -Times 0
        }
    }
    Context -name 'Should not throw'{
        it 'Calling the function by itself'{
            {Get-fsldiskinfo} | should not throw
        }
        it 'Valid inputs'{
            {Get-fsldiskinfo -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2' -csvfile 'C:\Users\danie\Documents\VHDModuleProject\test.csv'} | should not throw
        }
    }
}