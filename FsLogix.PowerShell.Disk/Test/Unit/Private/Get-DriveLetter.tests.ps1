$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
Describe $sut {
    BeforeAll{
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
    context -Name 'should throw'{
        it 'invalid path'{
            {get-driveletter 'C:\blah'} | should throw
        }
    }
    context -name 'should not throw'{
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
        <#it 'Guid'{
            $obj = New-MockObject -Type 'Microsoft.Management.Infrastructure.CimSession'
            mock -CommandName get-partition -MockWith {
                $obj | add-member @{AccessPaths = '\\?\Volume{test}'}
                $obj | add-member @{Type = 'Basic'}
                return $obj
            }
            {get-driveletter $path} | should not throw
        }#>
    }
}