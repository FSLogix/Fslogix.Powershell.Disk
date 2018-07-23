$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"
Describe $sut {
    Beforeall {
        mock -CommandName get-driveletter -MockWith {$true}
        mock -CommandName test-path -mockwith {$true}
        mock -CommandName dismount-FslDisk -MockWith {$true}
        mock -CommandName get-fslvhd -MockWith {
            [PSCustomObject]@{
                Name = 'test.vhd'
                Path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest'
            }
        }
        mock -CommandName remove-item -MockWith {$true}
    }
    Context -name 'Does not throw' {
        BeforeEach {
            mock -CommandName get-childitem -MockWith {
                [PSCustomObject]@{
                    Name = "hi.ost"
                }
            }
        }
        It 'Does not throw' {
            {get-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (2).vhd'} | should not throw
        }
        It 'switch remove' {
            {get-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (2).vhd' -remove} | should not throw
        }
        It 'index' {
            {get-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (2).vhd' -remove -start 1 -end 2} | should not throw
        }
        It 'output' {
            $output = {get-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (2).vhd' -output}
            $output.Count | should be 1
        }
        It 'full' {
            {get-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (2).vhd' -full} | should not throw
        }
    }
    Context -Name 'No VHDs in path' {
        mock -CommandName get-fslvhd -MockWith {
            return $null
        }
        it 'Should throw' {
            {get-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit\Public' } | out-null | should throw
        }
    }
    Context -name 'No ost in vhd' {
        mock -CommandName get-childitem -MockWith {return $null}
        it 'SHould give warning' {
            get-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx' -WarningVariable Warn
            $Warn.count -gt 0 | should be $true
        }
    }
    Context -name 'Invalid path' {
        Mock -CommandName test-path -MockWith {$false}
        it 'invalid path' {
            {get-fslostfile -path 'c:\blah'} | should throw
        }
    }
    Context -name 'Removing duplicate OST'{
        Mock -CommandName get-childitem -MockWith {
            [PSCustomObject]@{
                Name = "hi.ost"
            }
        }
        it 'Skipping deletion on one duplicate'{
            {get-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (2).vhd' -remove} | should not throw
        }
        Mock -CommandName get-childitem -MockWith {
            [PSCustomObject]@{
                Name = "hi.ost"
            },
            [PSCustomObject]@{
                Name = "hi2.ost"
            }
        }
        it 'Remove duplicate from duplicate ost'{
            {get-fslostfile -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test - Copy (2).vhd' -remove} | should not throw
        }
    }
}
