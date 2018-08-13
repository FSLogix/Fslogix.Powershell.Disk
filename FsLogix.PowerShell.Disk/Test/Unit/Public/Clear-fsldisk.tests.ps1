$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {

    BeforeAll {
        Mock -CommandName remove-item -MockWith {$true} -Verifiable
        Mock -CommandName Get-FslVhd -MockWith{
            [PSCustomObject]@{
                Path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
            }
        }
        Mock -CommandName dismount-FslDisk -MockWith {$true}
    }
    context -name 'Should throw' {
        it 'Invalid path'{
            {Clear-fsldisk -path "C:\blah"} | should throw
        }
        it 'Already cleared should give warning'{
            mock -CommandName get-fsldiskcontents -MockWith {$null}
            Clear-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd' -WarningVariable warn
            $warn.count | should be 1
        }
    }
    context -name 'Should not throw'{
        BeforeEach{
            mock -CommandName get-fsldiskcontents -MockWith {
                return get-childitem -path 'C:\Users\danie\Documents\VHDModuleProject\Sandbox.1.ps1'
            }
        }
        it 'Valid path'{
            {Clear-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'} | should not throw
        }
        it 'Valid path -force'{
            {Clear-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd' -force} | should not throw
        }
        it 'Used index range'{
            {clear-fsldisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2' -start 1 -end 2} | should not throw
        }
        it 'Valid path'{
            {Clear-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd' -dismount} | should not throw
        }
    }
}

