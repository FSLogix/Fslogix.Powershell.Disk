$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {

    Context -Name 'Outputs that should throw' {
        it 'Used incorrect extension path' {
            $incorrect_path = { get-fslvhd -Path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Public\set-FslPermission.ps1" }
            $incorrect_path | Should throw
        }
        it 'Used non-existing VHD'{
            $incorrect_path = { get-fslvhd -Path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\test4.vhd" }
            $incorrect_path | Should throw
        }
        it 'Used non-existing path'{
            $incorrect_path = {get-fslvhd -path "C:\blah"}
            $incorrect_path | should throw
        }
        it 'No vhds in path should give warning'{
            {get-fslvhd -path 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Public' -WarningAction stop} | should throw
        }
        it 'If starting index is greater than count'{
            {get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -start 999 -end 1000} | should throw
        }
        it 'If starting index is greater than ending index'{
            {get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -start 2 -end 1} | should throw
        }
    }
    context -name 'Test get-fslVHD'{
        BeforeEach{
            mock -CommandName Get-FslDisk -MockWith {
                return get-vhd 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
            }
        }
        it 'Correct vhd path'{
            {get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx'} | should not throw
        }
        It 'Takes pipeline input'{
            $vhd = get-childitem -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx"
            $vhd | get-fslvhd
        }
        it 'start and end index'{
            {get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx' -start 1 -end 1} | should not throw
        }
        it 'Index 1 to 3 should return 3 disks'{
            $vhd = get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -start 1 -end 3
            $vhd.count | should be 3
        }
        it 'Index 1 to 1 should return 1 disk'{
            $vhd = get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -start 1 -end 1
            $vhd.count | should be 1
        }
        it 'End index is greater than total count, should just return all vhds'{
            $vhd = get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest'
            $vhd2 = get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -start 1 -end 100
            $vhd2.count | should be $vhd.count
        }
        it 'If start or end index is 0, should ignore and return all vhds'{
            $vhd = get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest'
            $vhd2 = get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -start 1 -end 100
            $vhd2.count | should be $vhd.count
        }
    }
}