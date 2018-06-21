$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    Context -name "Outputs Should throw" {
        it 'Invalid path'{
            $Invalid_Command = {get-fsldiskcontents -vhdpath "C:\blah"} | Out-Null
            $Invalid_Command | should throw
        }
    }
    Context -name "Outputs should NOT throw" {
        it 'Valid path parameter' {
            $Command = {get-fsldiskcontents -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.6.vhdx"}
            $Command | should not throw
        }
    }
}