$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {

    Context -Name 'Outputs that should throw' {
    
        it 'Used non-existing path'{
            $Invalid_input = { ConvertTo-FslDisk -path "C:\User\dsfas" -convertTo vhd} | Out-Null
            $Invalid_input | should throw
        }
        it 'Converting vhdx to vhdx'{
            $Invalid_input = { ConvertTo-FslDisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\test.4.vhdx" -convertTo vhdx} | Out-Null
            $Invalid_input | should throw
        }
        it 'Converting vhd to vhd without overwrite parameter'{
            $Invalid_input = { ConvertTo-FslDisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd" -convertTo vhd} | Out-Null
            $Invalid_input | should throw
        }
        it 'Using non-existing convertTo'{
            $Invalid_input = { ConvertTo-FslDisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\test.4.vhdx" -convertTo vhdxasd} | Out-Null
            $Invalid_input | should throw
        }
        it 'Used path with no VHDs'{
            $Invalid_input = { ConvertTo-FslDisk -path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit" -convertTo vhd} | Out-Null
            $Invalid_input | should throw
        }
    }    
    Context -Name "Should not throw"{
        mock -CommandName Convert-VHD -MockWith {} -Verifiable
        it 'Valid path'{
            $Valid_input = { ConvertTo-FslDisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (2).vhd" -convertTo vhdx }
            $Valid_input | should not throw
        }
        It 'Asserts all verifiable mocks' {
            Assert-VerifiableMocks
        }
    }
}