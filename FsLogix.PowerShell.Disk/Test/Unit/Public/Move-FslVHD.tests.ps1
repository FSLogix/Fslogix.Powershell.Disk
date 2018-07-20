$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$Dest = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2'
$VHD = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811.vhd'
$invalidvhd ='C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\Invalid.vhd'
$validname = 'Daniel2_S-0-2-26-1944519217-1788772061-1800150966-14811'
$invalidname = 'hi'
describe $sut{
    BeforeAll{
        mock -CommandName New-FslDisk -MockWith {} -Verifiable
        mock -CommandName Copy-FslDiskToDisk -MockWith {} -Verifiable
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
        it 'VHD path is a directory'{
            {Move-FslVhd -VHD $Dest -Destination $Dest} | should throw
        }
        it 'Vhd is invalid'{
            {Move-FslVhd -VHD $invalidvhd -Destination $Dest} | should throw
        }
        it 'new name is invalid'{
            {Move-FslVhd -VHD $VHD -Destination $Dest -NewName $invalidname} | should throw
        }
    }
    Context -Name 'Should not throw'{
        it 'Valid parameters'{
            {Move-FslVhd -VHD $VHD -Destination $Dest} | should not throw
        }
        it 'NewName should match regex'{
            {Move-FslVhd -VHD $VHD -Destination $Dest -NewName $validname} | should not throw
        }
        it 'vhdformat is vhdx'{
            {Move-FslVhd -VHD $VHD -Destination $Dest -NewName $validname -VHDformat 'vhdx'} | should not throw
        }
    }
}