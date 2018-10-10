$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

$Path = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Tests\Private'

Describe $sut {
    BeforeAll {
        mock -CommandName Get-Childitem -MockWith {
            [PSCustomObject]@{
                Length = 100
            }
            [PSCustomObject]@{
                Length = 150
            }
        }
    }
    Context -name "Input" {
        it 'Normal input' {
            {Get-FslSize -path $Path} | should not throw
        }
        it 'Positional' {
            {Get-FslSize $Path} | should not throw
        }
        it 'pipeline' {
            {$Path | get-FslSize} | should not throw
        }
        it 'MB' {
            {Get-FslSize $Path -mb } | should not throw 
        }
        it 'Gb' {
            {Get-FslSize $Path -gb } | should not throw
        }
    }

    Context -name "Mock" {
        mock -CommandName Get-Childitem -MockWith {
            [PSCustomObject]@{
                Length = "100"
            }
        }
        it 'Should be 100' {
            $Command = Get-FslSize $Path
            $Command | should be 100
        }
        it 'assert mock called' {
            Assert-MockCalled -CommandName Get-childitem -Times 1
        }
    }
}