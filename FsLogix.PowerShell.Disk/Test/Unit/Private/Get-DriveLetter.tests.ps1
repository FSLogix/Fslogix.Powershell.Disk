$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
Describe $sut {
    # Need to find a way to mock add-partitionaccesspath
    # Keeps giving annoying error that you need to mock with a cimobject[]
    context -Name 'test guid without mock'{
        it 'Guid'{
            {get-driveletter 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\NoDl.vhdx'} | should not throw
        }
    }
    context -name 'mock command names'{
        BeforeEach{
            mock -CommandName New-Item -MockWith {}
            mock -CommandName Remove-Item -MockWith {}
            mock -CommandName Add-PartitionAccessPath -MockWith {}
    
            Mock -CommandName Get-FslDisk -MockWith {
                [PSCustomObject]@{
                    Attached = $false
                    Number = 1
                }
            }
            mock -CommandName Mount-DiskImage -MockWith {
                [PSCustomObject]@{
                    Number = 1
                }
            }
            mock -CommandName get-disk -MockWith {
                [PSCustomObject]@{
                    Number = 1
                    Location = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
                }
            }
            mock -CommandName get-partition -MockWith {
                [PSCustomObject]@{
                    AccessPaths = 'D:\'
                    Type = 'Basic'
                }
            }
            mock -CommandName Get-DiskImage -MockWith {
                [PSCustomObject]@{
                    Number = 1
                }
            }
        }
        it 'invalid path'{
            {get-driveletter 'C:\blah'} | should throw
        }
        it 'should not throw'{
            {get-driveletter $path} | should not throw
        }
        it 'attached'{
            Mock -CommandName Get-FslDisk -MockWith {
                [PSCustomObject]@{
                    Attached = $true
                    Number = 1
                }
            }
            {get-driveletter $path} | should not throw
        }
        it 'confirm output'{
            $command = get-driveletter $path
            $command | should be 'D:\'
        }
       
    }
}