$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    BeforeAll{
        mock -CommandName Remove-item {}

        #How to mock these?
        mock -CommandName New-VHD {}
        mock -CommandName Mount-VHD {}
        mock -CommandName Initialize-Disk {}
        mock -CommandName New-Partition {}
        mock -CommandName Format-Volume {}
    }
    context -Name "should throw"{
        it 'Name does not have a .vhd extension'{
            {New-FslDisk -NewVHDPath 'C:\Users\danie\Documents\VHDModuleProject\' -Name 'hi'} | should throw
        }
        it 'VHD already exists, user did not choose overwrite'{
            mock -CommandName test-path -MockWith {$true}
            {New-FslDisk -NewVHDPath 'C:\Users\danie\Documents\VHDModuleProject' -Name 'hi.vhd'} | should throw
        }
        it 'VHD name not matching regex should give warning'{
            mock -CommandName test-path -MockWith {$true}
            {New-FslDisk -NewVHDPath 'C:\Users\danie\Documents\VHDModuleProject' -Name 'hi.vhd' -overwrite -WarningAction Stop } | should throw
        }
        it 'generated vhd is corrupted'{
            mock -CommandName test-fslvhd -MockWith {$false}
            New-FslDisk -NewVHDPath 'C:\Users\danie\Documents\VHDModuleProject' -Name 'hi.vhd' -overwrite -WarningVariable warning
            $warning.count | should be 2
        }
        <#it 'format-volume failed'{
            mock -CommandName Format-Volume -MockWith {throw 'Error'}
            {New-FslDisk -NewVHDPath 'C:\Users\danie\Documents\VHDModuleProject' -Name 'hi.vhd' -overwrite} | should throw 'error'
        }#>
    }

    context -name 'Does not throw'{
        BeforeEach{
            mock -CommandName test-fslvhd -MockWith {$true}
        }
        it 'valid vhd and name'{
            {New-FslDisk -NewVHDPath 'C:\Users\danie\Documents\VHDModuleProject' -Name 'hi.vhd'} | should not throw
        }
        it 'overwrite'{
            {New-FslDisk -NewVHDPath 'C:\Users\danie\Documents\VHDModuleProject' -Name 'hi.vhd' -overwrite} | should not throw
        }
        it 'vhdparent'{
            {New-FslDisk -NewVHDPath 'C:\Users\danie\Documents\VHDModuleProject' -Name 'hi.vhd' -VHDParentPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd' -overwrite} | should not throw
        }
        it 'fixed'{
            {New-FslDisk -NewVHDPath 'C:\Users\danie\Documents\VHDModuleProject' -Name 'hi.vhd' -type 'fixed' -overwrite} | should not throw
        }
        it 'name matches regex'{
            {New-FslDisk -NewVHDPath 'C:\Users\danie\Documents\VHDModuleProject' -Name 'Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811.vhd' -overwrite} | should not throw
        }
        it 'custom user size'{
            {New-FslDisk -NewVHDPath 'C:\Users\danie\Documents\VHDModuleProject' -Name 'Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811.vhd' -size 15 -overwrite} | should not throw
        }
    }
}