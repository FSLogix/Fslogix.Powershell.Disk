$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {

    BeforeAll {
        if (-not(test-path -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhd")) {
            convertto-vhd -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx"
        }
    }
    Context -Name 'Outputs that should throw' {
        it 'User used non-existing Path'{
            $incorrect_path = { convertTo-VHDx -path "C:\blahasdf" }
            $incorrect_path | should throw
        }

        it 'Used path with .vhdx extension instead of .vhd, should throw' {
            $incorrect_path = { convertTo-VHDx -Path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -ErrorAction Stop }
            $incorrect_path | Should throw
        }
        it 'Used incorrect extension, should throw' {
            $incorrect_path = { convertTo-VHDx -path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Public\set-FslPermission.ps1"} 
            $incorrect_path | should throw
        }
        it 'Used non-existing VHD, should throw' {
            $invalid_path = { convertto-vhdx -path "C:\Users\Danie\Documents\test2.vhdx"} 
            $invalid_path | should throw
        }
        it 'Used directory path, should throw'{
            $invalid_path = { convertto-vhdx -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest" }
            $invalid_path | should throw
        }
    }

    Context -Name 'Test Remove-Item' {
        mock 'remove-item' -MockWith {$true}

        it 'If no pre existing VHDs exist, then remove-item should not be called.' {
            Assert-MockCalled -CommandName "remove-item" -Times 0 -ParameterFilter {$path -eq "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx"}
        }
    }
    Context -Name 'Test Convert to vhdx' {
       
        it 'Overwrite existing, Should not throw' {
            {convertto-vhdx -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhd" -overwrite } | should not throw
        }
        it 'Overwrite existing and delete old .vhd file, should not throw' {
            {convertto-vhdx -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhd" -overwrite -confirm } | should not throw
        }
    }
}