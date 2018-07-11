$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {

    Context -Name 'Outputs that should throw' {
        it 'Used incorrect extension path' {
            $incorrect_path = { get-fsldisk -Path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Public\set-FslPermission.ps1" } 
            $incorrect_path | Should throw
        }
        it 'Used folder path'{
            $incorrect_path = { get-fsldisk -Path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk" -ErrorAction Stop}
            $incorrect_path | Should throw
        }
        it 'Used non-existing VHD'{
            $incorrect_path = { get-fsldisk -Path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\test4.vhd" } 
            $incorrect_path | Should throw
        }
    }
    Context -name 'Test get-vhd'{
        Mock 'Get-VHD'
        
        it 'Should have no verbose lines'{
            #-Verbose 4>&1 pipelines verbose 4 to 1
            $verboseLine = get-fsldisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -Verbose 4>&1
            $verboseLine.count | Should be 0
        }
        it 'Assert the mock is called is only called once'{
            Assert-MockCalled -CommandName "get-vhd" -Times 1 -ParameterFilter {$path -eq "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx"}
        }
    }
    context -name 'Test get-fsldisk'{
        it 'Correct vhd path'{
            {get-fsldisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx'} | should not throw
        }
        It 'Takes pipeline input'{
            $vhd = get-childitem -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx"
            $vhd | get-fsldisk
        }
    }
}