$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    BeforeAll{
        Mock -CommandName Set-WmiInstance -MockWith {$true}
    }
    Context -name 'Should Throw' {
        
        it 'Invalid path' {
            $ErrorMessage = {Set-FslDriveLetter -vhdpath "C:\blah" -Letter 'D'}
            $ErrorMessage | should Throw 'Could not find path: C:\blah'
        }
        it 'Invalid Letter argument'{
            $ErrorMessage = {Set-FslDriveLetter -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -Letter 'blah'}
            $ErrorMessage | should Throw
        }
        it 'Letter is already in use'{
            $ErrorMessage = {Set-FslDriveLetter -vhdpath "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx" -Letter 'C'}
            $ErrorMessage | should Throw
        }

        it 'No Vhds in path should warn'{
            $hi = {Set-FslDriveLetter -vhdpath "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit\Private\Set-FslDriveLetter.tests.ps1" -Letter 'D'} | Out-Null
            $hi | should throw
        }
        it 'Letter is already mapped'{
            Set-FslDriveLetter -VHDPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx' -Letter 'T' | should throw
        }
    }
    Context -name 'Should not throw'{
        it 'Valid arguments'{
            {Set-FslDriveLetter -VHDPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd1.vhdx' -Letter 'D'} | should not throw
        }
    }
}