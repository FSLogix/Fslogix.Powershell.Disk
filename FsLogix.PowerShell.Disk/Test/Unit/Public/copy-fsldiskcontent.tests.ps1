$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
        Mock -CommandName get-driveletter -MockWith {} -Verifiable
        Mock -CommandName join-path -MockWith {$true}
        mock -CommandName get-childitem -MockWith { Write-Output @{
            Firstfilepath = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (2).vhd'
        }}
        mock -CommandName Copy-Item -MockWith {$true}

        it 'Invalid path should throw'{
            {copy-fsldiskcontent -FirstVHDPath 'C:\blah' -SecondVHDPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (3).vhd'} | should throw
        }

        it 'Valid path should not throw'{
            {copy-fsldiskcontent -FirstVHDPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (3).vhd' -SecondVHDPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (3).vhd'} | should throw
        }

        It 'Asserts all verifiable mocks' {
            Assert-VerifiableMocks
        }

        It 'Should not throw'{
            $cmd = Copy-FslDiskContent -VHD1 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.vhd' -vhd2 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd'
            $cmd | should not throw
        }
    }
