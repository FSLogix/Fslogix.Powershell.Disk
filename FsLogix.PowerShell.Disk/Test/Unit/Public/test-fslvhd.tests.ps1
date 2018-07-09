$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    it 'should throw'{
        {Test-FslVHD -path 'C:\blah'} | should throw
    }
    it 'If vhd is invalid or corrupted'{
        {test-fslvhd -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\Invalid.vhd'} | Out-Null | should throw
    }
    it 'should not throw'{
        {Test-fslvhd -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'} | should not throw
    }
}