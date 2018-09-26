$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    Context -name "Should throw"{
        Mock -CommandName Add-member -MockWith {$true}
        mock -CommandName export-Csv -MockWith {$true}
        
        it 'Invalid vhd path'{
            $invalid = {get-fslduplicatefiles -path "avasdf" -Csvpath "C:\Users\danie\test.csv"} 
            $invalid | should throw
        }
        it 'Invalid csv path'{
            $invalid = {get-FslDuplicateFiles -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -Csvpath "C:\blah"}
            $invalid | should throw
        }
        it 'Path to search is invalid'{
            $invalid = {get-FslDuplicateFiles -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -Folderpath "blah"}
            $invalid | should throw
        }
    }
    Context -name "Should not throw"{
        it "Valid path/csv path"{
            $cmd = {get-fslduplicatefiles -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -csvpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.csv"}
            $cmd | should not throw
        }
    }
}