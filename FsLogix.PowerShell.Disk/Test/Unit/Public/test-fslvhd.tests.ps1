$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    it 'should throw'{
        {Test-FslVHD -path 'C:\blah'} | out-null | should throw
    }
    it 'should not throw'{
        {Test-fslvhd -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.2.vhd'} | should not throw
    }
}