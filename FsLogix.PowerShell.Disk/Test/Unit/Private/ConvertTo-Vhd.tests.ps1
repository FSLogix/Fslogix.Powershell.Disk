$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {

    Context -Name 'Outputs that should throw' {

        it 'Used path with .vhd extension instead of .vhdx, should throw' {
            $incorrect_path = { convertTo-VHD -Path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd" } | Out-Null
            $incorrect_path | Should throw
        }
        it 'Used incorrect extension, should throw' {
            $incorrect_path = { convertTo-VHD -path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Public\set-FslPermission.ps1"} | Out-Null
            $incorrect_path | should throw
        }
        it 'Used non-existing VHD, should throw' {
            $invalid_path = { convertto-vhd -path "C:\Users\Danie\Documents\test2.vhdx" } | Out-Null
            $invalid_path | should throw
        }
        it 'Used directory path, should throw'{
            $invalid_path = { convertto-vhd -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest" } | Out-Null
            $invalid_path | should throw
        }
    }

    Context -Name 'Test Remove-Item' {
        mock 'remove-item'

        it 'If no pre existing VHDs exist, then remove-item should not be called.' {
            Assert-MockCalled -CommandName "remove-item" -Times 0 -ParameterFilter {$path -eq "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.3.vhdx"}
        }
    }
    Context -Name 'Test Convert to vhdx' {
        BeforeEach {
            if (-not(test-path -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.3.vhdx")) {
                convertto-vhdx -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.3.vhd"
            }
        }
        it 'Overwrite existing, Should not throw' {
            {convertto-vhd -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.3.vhdx" -overwrite "true"} | should not throw
        }
        it 'Overwrite existing and delete old .vhdx file, should not throw' {
            {convertto-vhd -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.3.vhdx" -overwrite "true" -confirm "true"} | should not throw
        }
    }
}