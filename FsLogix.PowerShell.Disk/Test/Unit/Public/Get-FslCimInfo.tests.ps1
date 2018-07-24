$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"
$VHD = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
$CSV = 'C:\Users\danie\Documents\VHDModuleProject\test.csv'

Describe $sut{
    context -Name 'Should throw'{
        it 'No .csv extension'{
            {get-fslciminfo -VHDpath $VHD -csvpath 'C:\blah'} | should throw
        }
    }
    Context -name 'Should not throw'{
        BeforeEach{
            Mock -CommandName Get-fslVhd -MockWith{
                [PSCustomObject]@{
                    Name = Split-Path $vhd -Leaf
                    Path = $VHD
                    Attached = $false
                }
            } -Verifiable
            mock -CommandName Get-Disk -MockWith{
                [PSCustomObject]@{
                    VHD = 'Disk'
                    CimClass = '1234'
                    CimInstanceProperties = 'none'
                    CimSystemProperties = 'NoneV2'
                    Location = "C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd"
                }
            } -Verifiable
            Mock -CommandName Export-Csv -MockWith{$null}
            mock -CommandName Mount-VHD -MockWith {$null}
            mock -CommandName dismount-FslDisk -MockWith {$null}
            mock -CommandName remove-item -MockWith {}
        }

        it 'test get-disk mock'{
            $disk = get-disk
            $disk.vhd | should be 'disk'
            $disk.CimClass | should be '1234'
            $disk.CimInstanceProperties | should be 'none'
            $disk.CimSystemProperties | should be 'NoneV2'
            $disk.Location | should be $VHD
        }
        it 'Mock Location and path should be equal'{
            $disk = get-disk
            $vhdtest = get-fslvhd -path $vhd
            $disk.Location | should be $vhdtest.path
        }
        it 'Test output'{
            $output = get-fslciminfo -path $VHD
            $output.VHD | should be 'testvhd1.vhd'
            $output.CimClass | should be '1234'
            $output.CimInstanceProperties | should be 'none'
            $output.CimSystemProperties | should be 'NoneV2'
        }
        it 'should not throw'{
            {Get-FslCimInfo -path $vhd} | should not throw
        }
        it 'csv'{
            {get-fslciminfo -path $vhd -csvpath $CSV} | should not throw
        }
        it 'Already attached'{
            Mock -CommandName Get-fslVhd -MockWith{
                [PSCustomObject]@{
                    Name = Split-Path $vhd -Leaf
                    Path = $VHD
                    Attached = $true
                }
            }
            {get-fslciminfo -path $vhd} | should not throw
        }
        it 'Asserts mock'{
            {get-fslciminfo -path $vhd -csvpath $CSV}
            Assert-MockCalled -CommandName Get-fslVhd -Times 1
            Assert-MockCalled -CommandName Get-Disk -Times 1
        }
        it 'Calls remove item'{
            Mock -CommandName test-path -MockWith {$true}
            {get-fslciminfo -path $vhd -csvpath $CSV} | should not throw
        }
    }
}