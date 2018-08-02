$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {

    context -Name 'mock get-diskimage'{
        BeforeEach{
            mock -CommandName get-diskimage -MockWith{
                [PSCustomObject]@{
                    ImagePath = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
                    Attached = 'true'
                }
            }
            mock -CommandName Get-Disk -MockWith{
                [PSCustomObject]@{
                    Number = 1
                    location = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
                }
            }
            mock -CommandName Get-FslDriveType -MockWith {
                return 'Fixed'
            }
        }
        it 'disknumber/vhdtype'{
            {get-fsldisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'} | should not throw
        }
    }
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
            { get-fsldisk -Path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\test4.vhd" } | Should throw
        }
        it 'Invalid VHd should fail get-vhd'{
            {get-fsldisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\Invalid.vhd' -ErrorAction Stop} | should throw
        }
        it 'Extension should be vhd'{
            {get-fsldisk -path 'C:\Users\danie\Documents\VHDModuleProject\JimMoyle\FsLogix.PowerShell.Disk\Test\Unit\Private\get-fslduplicatefiles.tests.ps1'} | should throw
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