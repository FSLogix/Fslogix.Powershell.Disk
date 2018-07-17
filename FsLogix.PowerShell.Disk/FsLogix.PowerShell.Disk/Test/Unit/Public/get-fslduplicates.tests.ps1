$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    Context -name "Should throw"{
        Mock -CommandName Get-FslDuplicateFiles -MockWith {} -Verifiable
        it 'Invalid vhd path'{
            $invalid = {get-fslduplicates -vhdpath "avasdf" -Csvpath "C:\Users\danie\test.csv"}
            $invalid | should throw
        }
        it 'invalid folder path within vhd'{
            $invalid = {get-FslDuplicates -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -Path 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit\Public\ConvertTo-fsldisk.tests.ps1' -Csvpath "C:\blah"}
            $invalid | should throw
        }
        it 'No Vhds in given path'{
            {get-fslduplicates -vhdpath "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit\Public"} | Out-Null | should throw
        }
    }
    Context -name "Should not throw"{

        it "Valid path/csv path"{
            $cmd = {get-fslduplicates -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -csvpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.csv"}
            $cmd | should not throw
        }
    }
}