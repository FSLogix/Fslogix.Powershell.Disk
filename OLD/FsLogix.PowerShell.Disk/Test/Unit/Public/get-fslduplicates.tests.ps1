$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    Context -name "Should throw"{
        Mock -CommandName Get-FslDuplicateFiles -MockWith {$true}
        it 'Invalid vhd path'{
            $invalid = {get-fslduplicates -vhdpath "avasdf" -Csvpath "C:\Users\danie\test.csv"}
            $invalid | should throw
        }
        it 'invalid folder path within vhd'{
            $invalid = {get-FslDuplicates -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -Path 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit\Public\ConvertTo-fsldisk.tests.ps1' -Csvpath "C:\blah"}
            $invalid | should throw
        }
    }
    Context -name "Should not throw"{
        BeforeEach{
            mock -CommandName Get-FslVhd -MockWith{
                [PSCustomObject]@{
                    Name = 'Test.vhd'
                    Path = 'C:\hi'
                }
            }
            mock -CommandName Get-FslDuplicateFiles -MockWith {$true}
        }

        it "Valid path/csv path"{
            {get-fslduplicates -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -csvpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.csv"} | should not throw
        }
        it 'Remove'{
            {get-fslduplicates -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -csvpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.csv" -remove} | should not throw
        }
        it 'Index'{
            {get-fslduplicates -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -csvpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.csv" -Remove -Start 1 -End 2} | should not throw
        }
    }
}