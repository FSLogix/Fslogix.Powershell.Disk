$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {

    Context -Name 'Outputs that should throw' {
        it 'Used incorrect extension path' {
            $incorrect_path = { get-fslvhd -Path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Public\set-FslPermission.ps1" }
            $incorrect_path | Should throw
        }
        it 'Used non-existing VHD'{
            $incorrect_path = { get-fslvhd -Path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\test4.vhd" }
            $incorrect_path | Should throw
        }
        it 'Used non-existing path'{
            $incorrect_path = {get-fslvhd -path "C:\blah"}
            $incorrect_path | should throw
        }
        it 'No vhds in path should give warning'{
            {get-fslvhd -path 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Public' -WarningAction stop} | should throw
        }
        it 'If starting index is greater than count'{
            {get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -start 999 -end 1000} | should throw
        }
        it 'If starting index is greater than ending index'{
            {get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -start 2 -end 1} | should throw
        }
        it 'Get-Fsldisk returns nothing, give warning'{
            mock -CommandName Get-FslDisk -MockWith {return $null}
            {get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx' -WarningAction Stop} | should throw
        }
        it 'No vhds in path should give warning'{
            mock -CommandName get-childitem -MockWith {$null}
            {Get-fslvhd -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -WarningAction Stop} | should throw
            
        }
    }
    context -name 'Test get-fslVHD'{
       
        BeforeEach{
            mock -CommandName Get-FslDisk -MockWith {
                [PSCustomObject]@{
                    Name = 'test.vhd'
                    Path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
                }
            } -Verifiable
        }
        it 'Correct vhd path'{
            {get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx'} | should not throw
        }
        It 'Takes pipeline input'{
            $vhd = get-childitem -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx"
            $vhd | get-fslvhd
        }
        it 'start and end index'{
            {get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx' -start 1 -end 1} | should not throw
        }
        it 'Index 1 to 3 should return 3 disks'{
            $vhd = get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -start 1 -end 3
            $vhd.count | should be 3
        }
        it 'End index is greater than total count, should just return all vhds'{
            $vhd = get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest'
            $vhd2 = get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -start 1 -end 100
            $vhd2.count | should be $vhd.count
        }
        it 'If start or end index is 0, should ignore and return all vhds'{
            $vhd = get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest'
            $vhd2 = get-fslVHD -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -start 1 -end 100
            $vhd2.count | should be $vhd.count
        }
        it 'Start index is greater than 1'{
            $vhd = Get-FslVhd -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -start 3 -end 5 
            $fisrtvhd = $vhd | Select-Object -First 1 
            $fisrtvhd.path | should be 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
        }
        it 'Each VHD should not be null'{
            $vhd = get-fslvhd -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -start 1 -end 4
            $vhd.count | should be 4
            foreach($disk in $vhd){
                $disk | should not be $Null
                $disk.name | should be "test.vhd"
            }
        }
    }
    Context -name 'Test output'{
        Mock -CommandName Get-FslDisk -MockWith {
            [PSCustomObject]@{
                Number              = 1
                Path                = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
                location            = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
                NumberOfPartitions  = 2
                Guid                = 'Test'
                ImagePath           = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
                Attached            = 'true'
                Size                = 10gb
                FileSize            = 8gb
            }
        }
        it 'Output 1'{
            $command = get-fslvhd 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
            $command.Number             | should be 1
            $command.Path               | should be 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
            $command.location           | should be 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - copy (2).vhd'
            $Command.NumberOfPartitions | should be 2
            $Command.Guid               | should be 'Test'
            $Command.Attached           | should be $true
            $Command.Size               | should be 10gb
            $Command.FileSize           | should be 8gb
        }
    }
}