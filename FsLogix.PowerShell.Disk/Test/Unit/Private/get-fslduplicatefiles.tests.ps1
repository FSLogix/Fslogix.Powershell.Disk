$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    Context -name "Should throw"{
        it 'Invalid vhd path'{
            $invalid = {get-fslduplicatefiles -path "avasdf" -Csvpath "C:\Users\danie\test.csv"} | Out-Null
            $invalid | should throw
        }
        it 'Invali csv path'{
            $invalid = {get-FslDuplicateFiles -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.vhd" -Csvpath "C:\blah"} | Out-Null
            $invalid | should throw
        }
    }
    Context -name "Should not throw"{
        it "Valid path/csv path"{
            $cmd = {get-fslduplicatefiles -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.vhd" -csvpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.csv"}
            $cmd | should not throw
        }
    }
}