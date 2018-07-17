$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    BeforeAll{
        Mock -CommandName Mount-VHD -MockWith {}
        Mock -CommandName Get-Disk -MockWith {}
        Mock -CommandName Get-Volume -MockWith {}
    }

    context -name 'Should throw'{
        it 'Invalid path'{
            {Remove-FslDriveLetter -path "C:\blah" } | should throw
        }
    }
    context -name 'Should not throw'{
        it 'Valid VHD'{
            {Remove-FslDriveLetter -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx'} | should not throw
        }
        
    }
}