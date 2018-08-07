$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
Describe $sut {

    context -Name 'mock get-diskimage'{
        BeforeEach{
            mock -CommandName get-diskimage -MockWith{
                [PSCustomObject]@{
                    ImagePath           = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
                    Attached            = 'true'
                    Size                = 10gb
                    FileSize            = 8gb
                }
            }
            mock -CommandName Get-Disk -MockWith{
                [PSCustomObject]@{
                    Number              = 1
                    location            = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
                    NumberOfPartitions  = 2
                    Guid                = 'Test'
                
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
            {get-fsldisk -path 'C:\Users\danie\Documents\VHDModuleProject\Disk\Fslogix.Powershell.Disk\FsLogix.PowerShell.Disk\Test\Unit\Private\Get-fsldisk.tests.ps1'} | should throw
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
    context -name 'Test outputs'{
        it 'output 1'{
            mock -CommandName get-diskimage -MockWith{
                [PSCustomObject]@{
                    ImagePath           = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
                    Attached            = 'true'
                    Size                = 10gb
                    FileSize            = 8gb
                }
            }
            mock -CommandName Get-Disk -MockWith{
                [PSCustomObject]@{
                    Number              = 1
                    location            = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
                    NumberOfPartitions  = 2
                    Guid                = 'Test'
                
                }
            }
            mock -CommandName Get-FslDriveType -MockWith {
                return 'Fixed'
            }
            $output = Get-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
            $output.ComputerName        | should be $env:COMPUTERNAME
            $output.name                | should be (split-path -path $path -leaf)
            $output.path                | should be $path
            $output.Guid                | should be 'Test'
            $output.VHDFormat           | should be 'vhd'
            $output.vhdtype             | should be 'fixed'
            $output.disknumber          | should be 1
            $output.NumberOfPartitions  | should be 2
            $output.SizeInGb            | should be 10
            $output.SizeInMb            | should be (10gb/1mb)
        }

        it 'output 2'{
            mock -CommandName get-diskimage -MockWith{
                [PSCustomObject]@{
                    ImagePath           = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
                    Attached            = 'true'
                    Size                = 15gb
                    FileSize            = 8gb
                }
            }
            mock -CommandName Get-Disk -MockWith{
                [PSCustomObject]@{
                    Number              = 2
                    location            = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
                    NumberOfPartitions  = 3
                    Guid                = 'Test'
                
                }
            }
            mock -CommandName Get-FslDriveType -MockWith {
                return 'CD-ROM'
            }
            $output = Get-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
            $output.ComputerName        | should be $env:COMPUTERNAME
            $output.name                | should be (split-path -path $path -leaf)
            $output.path                | should be $path
            $output.Guid                | should be 'Test'
            $output.VHDFormat           | should be 'vhd'
            $output.vhdtype             | should be 'CD-ROM'
            $output.disknumber          | should be 2
            $output.NumberOfPartitions  | should be 3
            $output.SizeInGb            | should be 15
            $output.SizeInMb            | should be (15gb/1mb)
        }
    }
}