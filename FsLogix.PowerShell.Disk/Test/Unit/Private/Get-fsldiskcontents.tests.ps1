$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {

    Context -name "Outputs Should throw" {
        #mock -CommandName get-fslvhd -MockWith {} -Verifiable
        #mock -CommandName get-driveletter -MockWith {} -Verifiable
        it 'Invalid vhd path'{
            $Invalid_Command = {get-fsldiskcontents -vhdpath "C:\blah"} 
            $Invalid_Command | should throw
        }
        it 'Invalid folder path'{
            $Invalid_Command = {get-fsldiskcontents -VHDPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx' -FolderPath 'blah'}
            $Invalid_Command | should throw
        }
    }
    Context -name "Outputs should NOT throw" {
        it 'Valid path parameter' {
            $Command = {get-fsldiskcontents -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx"}
            $Command | should not throw
        }
    }
}