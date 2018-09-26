$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    it 'Should not throw'{
        {Get-FslFunctions} | should not throw
    }
    it 'path'{
        {Get-FslFunctions -path 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Public\Get-FslFunctions.ps1' } | should not throw
    }
    it 'should throw'{
        {Get-Fslfunctions -path 'C:\blah'} | should throw
    }
    it 'Invalid path, must be powershell function'{
        {Get-fslfunctions -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest'} | should throw
    }
}