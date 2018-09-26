$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"
Describe $sut{
    it 'should not throw'{
        {Set-FslLabel -user 'Daniel' -Path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811.vhd'} | should not throw
    }
    it 'Should exist now'{
        $command = (Get-WMIObject Win32_Volume).where{$_.label -eq 'Daniel'}
        $command | should not be $null
    }
}