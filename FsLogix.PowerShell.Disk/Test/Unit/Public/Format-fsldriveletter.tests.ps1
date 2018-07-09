$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    context -name 'should throw'{
        it 'No VHDs in path'{
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Public' -Command 'set'} | out-null | should throw
        }
        it 'Invalid Command name'{
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -Command 'asdf'} | should throw
        }
        it 'Invalid Letter for Set command'{
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -Command 'set' -Letter 'af'} | should throw
        }
        it 'User did not enter a letter for set command'{
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -Command 'set'} | should throw
        }
    }
    context -Name 'Should not throw'{
        BeforeEach{
            mock -CommandName Set-fsldriveletter -MockWith {} -Verifiable
            mock -CommandName Remove-FslDriveLetter -MockWith {} -Verifiable
            mock -CommandName get-driveletter -MockWith {} -Verifiable
            mock -CommandName dismount-fsldisk -MockWith {} -Verifiable
        }
        it 'Valid get input'{
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -Command 'get'} | should not throw
        }
        it 'Valid remove input'{
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -Command 'remove'} | should not throw
        }
        it 'Valid set inputs'{
            {Format-FslDriveLetter -VhdPath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -Command 'set' -Letter 'D'} | should not throw
        }
    }
}