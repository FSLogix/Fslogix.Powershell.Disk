$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    BeforeAll {
        mock -CommandName Copy-Item -MockWith {$true}
    }
    Context -name 'Should throw' {
        it 'Invalid path should throw' {
            {Copy-FslDiskToDisk -FirstVHDPath 'C:\blah' -SecondVHDPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'} | should throw
        }

        it 'First Folderpath within VHD was invalid' {
            {Copy-FslDiskToDisk -VHD1 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\TestVHD2.vhd' -file 'blah' -vhd2 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'} | should throw
        }
        it  'Second Folderpath within VHD was invalid' {
            {Copy-FslDiskToDisk -VHD1 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\TestVHD2.vhd' -file2 'blah' -vhd2 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'} | should throw
        }
        it 'First file path was invalid' {
            {Copy-FslDiskToDisk -VHD1 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd' -file 'blah' -vhd2 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'} | should throw
        }
        it 'Second file path was invalid' {
            {Copy-FslDiskToDisk -VHD1 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd' -file2 'blah' -vhd2 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'} | should throw
        }
        It 'VHD contents are emtpy' {
            {Copy-FslDiskToDisk -VHD1 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\empty.vhdx' -vhd2 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -Overwrite } | should throw
        }
    }
    Context -name 'Should not throw'{
        It 'Should not throw -overwrite'{
            {Copy-FslDiskToDisk -VHD1 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd' -vhd2 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -Overwrite } | should not throw
        }
        It 'Should not throw'{
            {Copy-FslDiskToDisk -VHD1 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd' -vhd2 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'} | should not throw
        }
    }
}
