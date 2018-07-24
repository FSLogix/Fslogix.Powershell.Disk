$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$vhd = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'

Describe $sut{

    mock -CommandName get-FslDuplicateFiles -MockWith {$true} -Verifiable
    mock -CommandName optimize-vhd -MockWith {$true}

    context -name 'should throw' {
        BeforeEach {
            mock -CommandName get-fsldisk -MockWith {
                [PSCustomObject]@{
                    VHDtype  = 'Fixed'
                    Attached = $false
                }
            }
        }

        it 'Invalid path should throw' {
            $invalid_cmd = {Optimize-FslDisk -path "C:\blah" -mode 'Quick'}
            $invalid_cmd | should throw
        }

        it 'Should Throw, using fixed vhd' {
            $invalid_cmd = {Optimize-FslDisk -path $vhd -mode 'quick'}
            $invalid_cmd | should throw
        }
        it 'VHD is attached' {
            mock -CommandName get-fsldisk -MockWith {
                [PSCustomObject]@{
                    VHDtype  = 'Dynamic'
                    Attached = $true
                }
            }
            {Optimize-FslDisk -path $vhd} | should throw
        }
    }

    context -Name 'Mock get-fsldisk' {
        BeforeEach {
            mock -CommandName get-fsldisk -MockWith {
                [PSCustomObject]@{
                    VHDtype  = 'Dynamic'
                    Attached = $false
                }
            }
        }
        it 'Dynamic, not attached should not throw' {
            {Optimize-FslDisk -path $vhd} | should not throw
        }
        it 'Delete' {
            {Optimize-FslDisk -path $vhd -Delete} | should not throw
        }
    }
}