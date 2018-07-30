$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"
$item1 = [PSCustomObject]@{
    length = 5mb
}
$item2 = [PSCustomObject]@{
    length = 10mb
}
$item3 = [PSCustomObject]@{
    length = 14gb
}
$item4 = [PSCustomObject]@{
    Name = 'NotALength'
}
Describe $sut{
    context -Name "should throw"{
        it 'Invalid path'{
            {get-fslfoldersize -Path 'c:\blah'} | should throw
        }
    }
    context -Name 'Should not throw'{
        BeforeEach{
            mock -CommandName Get-ChildItem -MockWith {
                return @($item1,$item2,$item4)
            }
        }
        it 'Valid, should skip if no length property'{
            {get-fslfoldersize -path 'C:\Users\danie\Documents\VHDModuleProject'} | should not throw
        }
        it 'confirm output'{
            $output = get-fslfoldersize -path 'C:\Users\danie\Documents\VHDModuleProject'
            $output.count | should be 1
            $output | should be 15
        }
        it 'gb'{
            mock -CommandName Get-ChildItem -MockWith {
                return @($item3)
            }
            $output = get-fslfoldersize -path 'C:\Users\danie\Documents\VHDModuleProject' -gb
            $output.count | should be 1
            $output | should be 14
        }
    }
}