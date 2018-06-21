$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    Context -name "Outputs Should throw" {
        ## Need to add test cases
    }
    Context -name "Outputs should NOT throw" {
        it 'Valid path parameter' {
            $Command = {get-fsldiskcontents -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.6.vhdx"}
            $Command | should not throw
        }
    }
}