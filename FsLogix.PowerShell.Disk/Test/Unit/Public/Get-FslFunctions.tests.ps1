$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    it 'Should not throw'{
        {Get-FslFunctions} | should not throw
    }
    it 'Should not throw'{
        {Get-FslFunctions -Private} | should not throw
    }
}