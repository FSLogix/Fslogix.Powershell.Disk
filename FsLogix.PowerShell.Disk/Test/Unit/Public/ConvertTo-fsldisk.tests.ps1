$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    BeforeAll{
        Mock -CommandName ConvertTo-Vhd -MockWith {$true}
        Mock -CommandName ConvertTo-Vhdx -MockWith {$true}
    }

    Context -Name 'Outputs that should throw' {

        it 'Used non-existing path'{
            $Invalid_input = { ConvertTo-FslDisk -path "C:\User\dsfas" -convertTo vhd}
            $Invalid_input | should throw
        }
        it 'Converting vhdx to vhdx'{
            $Invalid_input = { ConvertTo-FslDisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx" -convertTo vhdx}
            $Invalid_input | should throw
        }
        it 'Converting vhd to vhd without overwrite parameter'{
            $Invalid_input = { ConvertTo-FslDisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\TestVHD2.vhd" -convertTo vhd}
            $Invalid_input | should throw
        }
        it 'Using non-existing convertTo'{
            $Invalid_input = { ConvertTo-FslDisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\test.4.vhdx" -convertTo vhdx}
            $Invalid_input | should throw
        }
        it 'Used path with no VHDs'{
            $Invalid_input = { ConvertTo-FslDisk -path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit" -convertTo vhd}
            $Invalid_input | should throw
        }
    }
    Context -Name "Should not throw"{
        mock -CommandName Convert-VHD -MockWith {$true}
        mock -CommandName remove-item -MockWith {$true}
        it 'Valid path'{
            $Valid_input = { ConvertTo-FslDisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd" -convertTo vhdx -overwrite -RemoveOld }
            $Valid_input | should not throw
        }
        It 'Asserts all verifiable mocks' {
            Assert-VerifiableMocks
        }
    }
    Context -Name "Additional tests"{
        mock -CommandName Convert-VHD -MockWith {$true}
        mock -CommandName remove-item -MockWith {$true}

        it 'Get-FslDisk vhd'{
            Mock -CommandName Get-FslDisk -MockWith{return get-vhd 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'}
            { ConvertTo-FslDisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd" -convertTo vhdx -overwrite -RemoveOld } | should not throw
        }
        it 'Get-FslDisk vhdx' {
            Mock -CommandName Get-FslDisk -MockWith{return get-vhd 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'}
            Assert-VerifiableMocks
        }
    }
}