$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    BeforeAll{
        mock -CommandName Mount-DiskImage -MockWith {} -Verifiable
        mock -CommandName get-disk -MockWith {}
        mock -CommandName get-partition -MockWith {}
    }
    context -Name 'should throw'{
        it 'invalid path'{
            {get-driveletter 'C:\blah'} | should throw
        }
    }
    context -name 'should not throw'{
        mock -CommandName get-diskimage -MockWith{
            return [PSCustomObject]@{
                Attached = $false
            }
        }
        it 'should not throw'{
            {get-driveletter 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'} | should not throw
        }
        it 'attached'{
            mock -CommandName get-diskimage -MockWith{
                [PSCustomObject]@{
                    Attached = $true
                }
            }
            {get-driveletter 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'} | should not throw
        }
    }
    
}