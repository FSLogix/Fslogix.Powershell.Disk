$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    BeforeAll {
        mock -CommandName get-fslvhd -MockWith {
            return get-vhd 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'
        }
    }

    Context -name "Outputs Should throw" {
        it 'Invalid vhd path' {
            $Invalid_Command = {get-fsldiskcontents -vhdpath "C:\blah"}
            $Invalid_Command | should throw
        }
        it 'Invalid folder path' {
            $Invalid_Command = {get-fsldiskcontents -VHDPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx' -FolderPath 'blah'}
            $Invalid_Command | should throw
        }
        it 'Contents are empty should give warning'{
            Mock -CommandName get-childitem -MockWith {$null}
            get-fsldiskcontents -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -WarningVariable warn
            $warn.count -gt 0 | should be $true
        }
    }
    Context -name "Outputs should NOT throw" {
        it 'Valid path parameter' {
            {get-fsldiskcontents -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx"} | should not throw
        }
        it 'recurse' {
            {get-fsldiskcontents -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -recurse} | should not throw
        }
        it 'dismount' {
            {get-fsldiskcontents -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -dismount} | should not throw
        }
    }
}