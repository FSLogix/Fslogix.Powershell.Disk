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
    }
    context -name 'Test get-fslVHD'{
        it 'Correct vhd path'{
            {get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx'} | should not throw
        }
        It 'Takes pipeline input'{
            $vhd = get-childitem -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx"
            $vhd | get-fslvhd
        }
    }
}