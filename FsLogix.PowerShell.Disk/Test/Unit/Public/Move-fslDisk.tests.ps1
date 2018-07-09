$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"
Describe $sut {

    Context -name 'Is attached should throw' {
        mount-vhd -Path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'
        it 'VHD is attached' {
            {move-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -Destination 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2'} | out-null | should throw
        }
        dismount-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'
    }
    Context -name "Should throw" {
     
        it 'Invalid path' {
            {move-FslDisk -path 'C:\blah' -Destination 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx'} | should throw
        }
        it 'Invalid destination' {
            {move-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx' -Destination 'C:\blah'} | should throw
        }
        it 'VHD already exist in destination and use did not choose overwrite' {
            {move-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx' -Destination 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx'}
        }

      

    }
    Context -name 'Should not throw' {
        BeforeEach {
            Mock -CommandName Move-item -MockWith {$true}
            mock -CommandName remove-item -MockWith {$true}
            Mock -CommandName Split-Path -MockWith {$true}
        }
        it 'Move VHD and overwrite' {
            {move-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx' -Destination 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx' -Overwrite} | should not throw
        }
    }
}