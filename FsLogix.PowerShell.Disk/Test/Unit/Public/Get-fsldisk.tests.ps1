$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {

    Context -Name 'Outputs that should throw' {
        it 'Used incorrect extension path' {
            $incorrect_path = { get-fsldisk -Path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Public\set-FslPermission.ps1" } | Out-Null
            $incorrect_path | Should throw
        }
        it 'Used folder path'{
            $incorrect_path = { get-fsldisk -Path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk" } | Out-Null
            $incorrect_path | Should throw
        }
        it 'Used non-existing VHD'{
            $incorrect_path = { get-fsldisk -Path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\test4.vhd" } | Out-Null
            $incorrect_path | Should throw
        }
    }
    Context -name 'Test get-vhd'{
        Mock 'Get-VHD'
        
        it 'Should return Verbose Lines'{
            #-Verbose 4>&1 pipelines verbose 4 to 1
            $verboseLine = get-fsldisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd" -Verbose 4>&1
            $verboseLine.count | Should BeGreaterThan 0
        }
        it 'Assert the mock is called is only called once'{
            Assert-MockCalled -CommandName "get-vhd" -Times 1 -ParameterFilter {$path -eq "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd"}
        }
    }
    context -name 'Test get-fsldisk'{
        it 'Should not throw'{
            {get-fsldisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd'} | should not throw
        }
    }
}