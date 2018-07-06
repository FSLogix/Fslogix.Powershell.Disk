$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    
    BeforeAll {
        if (-not(test-path -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\TestVHD1.vhdx")) {
            convertto-vhdx -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\TestVHD1.vhd"
        }
    }

    Context -Name 'Outputs that should throw' {
        it 'Invalid path'{
            $incorrect_path = { convertTo-VHD -Path "C:\blah" -ErrorAction Stop } 
            $incorrect_path | Should throw
        }

        it 'Used path with .vhd extension instead of .vhdx, should throw' {
            $incorrect_path = { convertTo-VHD -Path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhd" -ErrorAction Stop}
            $incorrect_path | Should throw
        }
        it 'Used incorrect extension, should throw' {
            $incorrect_path = { convertTo-VHD -path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Public\set-FslPermission.ps1" -ErrorAction Stop}
            $incorrect_path | should throw
        }
        it 'Used non-existing VHD, should throw' {
            $invalid_path = { convertto-vhd -path "C:\Users\Danie\Documents\test2.vhdx" -ErrorAction Stop } 
            $invalid_path | should throw
        }
        it 'Used directory path, should throw'{
            $invalid_path = { convertto-vhd -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest" -ErrorAction Stop } 
            $invalid_path | should throw
        }
        it 'VHD already exists in this location'{
            $Already_Exist = {convertTo-VHD -Path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -ErrorAction Stop} 
            $Already_Exist | should throw
        }
    }

    Context -Name 'Test Remove-Item' {
        mock 'remove-item' -MockWith {$true}

        it 'Overwrite existing, Should throw' {
            {convertto-vhd -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\TestVHD1.vhdx" -overwrite -ErrorAction Stop} | should throw
        }
    }
    Context -Name 'Test Convert to vhd' {
        
        it 'Overwrite existing, Should not throw' {
            {convertto-vhd -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\TestVHD1.vhdx" -overwrite} | should not throw
        }
        it 'Overwrite existing and delete old .vhdx file, should not throw' {
            {convertto-vhd -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\TestVHD1.vhdx" -overwrite -confirm} | should not throw
        }
    }
}