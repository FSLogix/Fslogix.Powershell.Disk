$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
        mock -CommandName Copy-Item -MockWith {$true}
        mock -CommandName remove-item -MockWith {$true}

        it 'Invalid path should throw'{
            {copy-fsldiskcontent -FirstVHDPath 'C:\blah' -SecondVHDPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'} | should throw
        }

        it 'First Folderpath within VHD was invalid'{
            {Copy-FslDiskContent -VHD1 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\TestVHD2.vhd' -file 'blah' -vhd2 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'} | should throw
        }
        it  'Second Folderpath within VHD was invalid'{
            {Copy-FslDiskContent -VHD1 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\TestVHD2.vhd' -file2 'blah' -vhd2 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'} | should throw
        }

        It 'Asserts all verifiable mocks' {
            Assert-VerifiableMocks
        }

        It 'Should not throw'{
            $cmd = {Copy-FslDiskContent -VHD1 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\TestVHD2.vhd' -vhd2 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -Overwrite}
            $cmd | should not throw
        }
    }
