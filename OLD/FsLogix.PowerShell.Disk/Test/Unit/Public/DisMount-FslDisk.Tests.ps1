$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"



Describe $sut {
    $path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
    BeforeAll{
        mock -CommandName Get-Item -MockWith {
            [PSCustomObject]@{
                Extension = '.vhd'
                BaseName = 'TestVHD1'
                Attributes = 'Archive'
            }
        }
        mock -CommandName Get-Disk -MockWith {
            [PSCustomObject]@{
                Model = 'Virtual Disk'
                Location = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
            }
        }
        mock -CommandName Dismount-DiskImage -MockWith {}
    }
    Context -Name 'Should Throw'{
        it 'Invalid VHD Path'{
            {Dismount-fsldisk -path 'C:\blah'} | should throw
        }
        it 'User inputted directory'{
            mock -CommandName Get-Item -MockWith {
                [PSCustomObject]@{
                    Extension = $null
                    BaseName = 'TestVHD1'
                    Attributes = 'Directory'
                }
            }
            {Dismount-fsldisk -path 'C:\Users\danie\Documents\VHDModuleProject\Disk\Fslogix.Powershell.Disk'} | should throw
        }
        it 'User used non-vhd for path'{
            mock -CommandName Get-Item -MockWith {
                [PSCustomObject]@{
                    Extension = '.ps1'
                    BaseName = 'TestVHD1'
                    Attributes = 'Archive'
                }
            }
            {Dismount-fsldisk -path 'C:\Users\danie\Documents\VHDModuleProject\Disk\Fslogix.Powershell.Disk\FsLogix.PowerShell.Disk\Private\ConvertTo-VHD.ps1'} | should throw
        }
        it 'Dismountall, but no VHDs attached'{
            mock -CommandName Get-Disk -MockWith {
                [PSCustomObject]@{
                    Model = 'Hello World'
                    Location = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
                }
            }
            dismount-FslDisk -DismountAll -WarningVariable Warn
            $Warn.count | should be 1
            $Warn | should be "Could not find any attached VHD's."
        }
        it 'Weird bug'{
            mock -CommandName Get-Item -MockWith {
                [PSCustomObject]@{
                    Extension = $null
                    BaseName = 'TestVHD1'
                    Attributes = 'Archive'
                }
            }
            {Dismount-fsldisk -path 'C:\Users\danie\Documents\VHDModuleProject\Disk\Fslogix.Powershell.Disk\FsLogix.PowerShell.Disk\Private\ConvertTo-VHD.ps1'} | should throw
        }
    }
    Context -name 'Should not throw'{
        it 'Dismountall'{
            mock -CommandName Get-Disk -MockWith {
                [PSCustomObject]@{
                    Model = 'Virtual Disk'
                    Location = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
                }
            }
            {Dismount-fsldisk -DismountAll} | should not throw
        }
        it 'Correct path'{
            mock -CommandName Get-Item -MockWith {
                [PSCustomObject]@{
                    Extension = '.vhd'
                    BaseName = 'TestVHD1'
                    Attributes = 'Archive'
                }
            }
            {dismount-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'} | should not throw
        }
    }
}