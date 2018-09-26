$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$VHD = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd3.vhd'

Describe $sut {
    BeforeAll{
        mock -CommandName Optimize-VHD -MockWith {} -Verifiable
        mock -CommandName Get-FslDuplicates -MockWith {}
    }
    context 'Attached VHD should throw'{
        mock -CommandName Get-FslVHD -MockWith {
            [PSCustomObject]@{
                Path = $VHD
                Attached = $true
            }
        }
        it 'throws'{
            {Compress-FslDisk -VHD $VHD} | should throw
        }
    }
    context 'Does not throw'{
        mock -CommandName Get-FslVHD -MockWith {
            [PSCustomObject]@{
                Path = $VHD
                Attached = $false
            }
        }
        it 'does not throw'{
            {Compress-FslDisk -VHD $VHD} | should not throw
        }
        it 'dismount'{
            {Compress-FslDisk -VHD $VHD } | should not throw
        }
        it 'attached'{
            mock -CommandName Get-FslVHD -MockWith {
                [PSCustomObject]@{
                    Path = $VHD
                    Attached = $true
                }
            }
            {Compress-FslDisk -VHD $VHD -dismount} | should throw
        }
    }
}