$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$Dest = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2'
$VHD = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811.vhd'
$VHDFlipFLop = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\S-0-2-26-1944519217-1788772061-1800150966-14812_Daniel.vhd'
$VHDDir = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest3'
$invalidvhd ='C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\Invalid.vhd'
describe $sut{ # 100% pester
    BeforeAll{
        mock -CommandName New-FslDisk -MockWith {} -Verifiable
        mock -CommandName Copy-FslDiskToDisk -MockWith {} -Verifiable
        mock -CommandName rename-item -MockWith {}
    }
    Context -name 'Should throw'{
        it 'Invalid VHD path'{
            {move-fslvhd -VHD 'C:\blah' -Destination $Dest} | should throw
        }
        it 'Destination is not a directory'{
            {move-Fslvhd -VHD $VHD -Destination 'C:\Users\danie\Documents\VHDModuleProject\Old scripts\set-FslPermission.ps1'} | should throw
        }
        it 'Invalid destination path'{
            {Move-FslVhd -VHD $VHD -Destination 'C:\blah' } | should throw
        }
        it 'Vhd is invalid'{
            {Move-FslVhd -VHD $invalidvhd -Destination $Dest} | should throw
        }
    }
    Context -Name 'Should not throw'{
        it 'Valid parameters'{
            {Move-FslVhd -VHD $VHD -Destination $Dest} | should not throw
        }
        it 'NewName should match regex'{
            {Move-FslVhd -VHD $VHD -Destination $Dest } | should not throw
        }
        it 'vhdformat is vhdx'{
            {Move-FslVhd -VHD $VHD -Destination $Dest -VHDformat 'vhdx'} | should not throw
        }
        it 'rename'{
            {Move-FslVhd -VHD $VHD -Destination $Dest} | should not throw
        }
        it 'rename flipflop'{
            {Move-FslVhd -VHD $VHDFlipFLop -Destination $Dest} | should not throw
        }
        it 'vhd directory'{
            {Move-FslVhd -VHD $VHDDir -Destination $Dest} | should not throw
        }
    }
}