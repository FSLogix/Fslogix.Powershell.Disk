$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    Mock -CommandName Remove-item -MockWith {$true}
    Mock -CommandName get-fslvhd -MockWith {} -Verifiable
    Mock -CommandName Export-csv -MockWith {$true}
    Context -Name "Should throw"{
        it 'Incorrect VHD path'{
            $command = {get-fsldiskinfo -path 'C:\blah'} 
            $command | should throw
        }
        it 'Incorrect Csv path'{
            $command = {get-fsldiskinfo -csvfile 'C:\blah'} 
            $command | should throw
        }
    }
    Context -name 'Should not throw'{
        it 'Calling the function by itself'{
            {Get-fsldiskinfo} | should not throw
        }
        it 'Valid inputs'{
            {Get-fsldiskinfo -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -csvfile 'C:\Users\danie\Documents\VHDModuleProject\test.csv'} | should not throw
        }
          it 'Asserts all verifiable mocks' {
            Assert-VerifiableMocks
        }
        
    }
}