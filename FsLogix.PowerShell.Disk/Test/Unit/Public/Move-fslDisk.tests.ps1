$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$dest = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2'
$vhd = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'

Describe $sut {
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
        it 'VHD already exists, did not overwrite'{
            Mock -CommandName Get-FslVHD -MockWith {
                [PSCustomObject]@{
                    Path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
                    Attached = $false
                }
            }
            {move-fsldisk -path $vhd -Destination $dest} | should throw
        }
        it 'Attached'{
            Mock -CommandName Get-FslVHD -MockWith {
                [PSCustomObject]@{
                    Path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
                    Attached = $true
                }
            }
            {move-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd' -Destination $dest} | should throw
        }

    }
    Context -name 'Should not throw' {
        BeforeEach {
            Mock -CommandName Move-item -MockWith {$true}
            mock -CommandName remove-item -MockWith {$true}
        }
        it 'Move VHD and overwrite' {
            {move-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx' -Destination 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx' -Overwrite} | should not throw
        }
        it 'VHD already exists, overwrite'{
            Mock -CommandName Get-FslVHD -MockWith {
                [PSCustomObject]@{
                    Path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
                    Attached = $false
                }
            }
            {move-fsldisk -path $vhd -Destination $dest -Overwrite } | should not throw
        }
        it 'Move vhd, does not already exist'{
            {move-fsldisk -path $vhd -Destination 'C:\Users\danie\Documents\VHDModuleProject'} | should not throw
        }
    }
}