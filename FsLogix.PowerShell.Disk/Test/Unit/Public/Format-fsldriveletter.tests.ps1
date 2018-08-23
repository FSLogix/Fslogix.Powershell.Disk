$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    context -name 'should throw'{
        it 'No VHDs in path'{
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Public' -Command 'set'} | should throw
        }
        it 'Invalid Command name'{
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -asdf} | should throw
        }
        it 'Invalid Letter for Set command'{
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -set -Letter af} | should throw
        }
    }
    context -Name 'Should not throw'{
        BeforeEach{
            mock -CommandName Set-fsldriveletter -MockWith {} -Verifiable
            mock -CommandName Remove-FslDriveLetter -MockWith {} -Verifiable
            mock -CommandName get-driveletter -MockWith {} -Verifiable
            mock -CommandName dismount-fsldisk -MockWith {} -Verifiable
        }
        it 'Valid get input'{
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -get} | should not throw
        }
        it 'Valid remove input'{
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -remove} | should not throw
        }
        it 'Valid set inputs'{
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -set -Letter 'D'} | should not throw
        }
        it 'Assign'{
            mock -CommandName Get-Fsldisk -MockWith {
                [PSCustomObject]@{
                    Attached = $true
                    Path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
                }
            }
            Mock -CommandName Mount-DiskImage -MockWith {
                [PSCustomObject]@{
                    Number = 1
                }
            }
            Mock -CommandName Get-Diskimage -MockWith {}
            Mock -CommandName Get-Disk -MockWith {
                
            }
            Mock -CommandName Get-Partition -MockWith {
                [PSCustomObject]@{
                    Type = Basic
                }
            }
            mock -CommandName Set-Partition -MockWith {}
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd' -Assign} | should not throw
        }
        it 'All letters fail.'{
            mock -CommandName Get-Fsldisk  -MockWith {
                [PSCustomObject]@{
                    Attached = $true
                    Path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
                }
            }
            Mock -CommandName Mount-DiskImage -MockWith {
                [PSCustomObject]@{
                    Number = 1
                }
            }
            Mock -CommandName Get-Diskimage -MockWith {
                [PSCustomObject]@{
                    Number = 1
                }
            }
            Mock -CommandName Get-Disk -MockWith {
                [PSCustomObject]@{
                    Location = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
                }
                
            }
            Mock -CommandName Get-Partition -MockWith {
                [PSCustomObject]@{
                    Type = Basic
                }
            }
            mock -CommandName Set-Partition -MockWith {throw}
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd' -Assign} | should throw
        }
    }
}