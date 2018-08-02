$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    it 'should not throw'{
        {Get-fslDriveType 0} | should not throw
    }
    it 'should be fixed'{
        $cmd = get-fsldrivetype 0
        $cmd | Should be 'fixed'
    }
    it 'warning'{
        {get-fsldrivetype 1} | should throw
    }
}