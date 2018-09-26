$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    BeforeAll {
        mock -CommandName get-driveletter -MockWith {} -Verifiable
        mock -CommandName Get-FslAvailableDriveLetter -MockWith {} -Verifiable
    }
    context -name 'should throw' {
        it 'Invalid Path' {
            {Mount-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Private' } | out-null | should throw
        }
        mock -CommandName Get-FslAvailableDriveLetter -MockWith {'A','B'}
        it 'More VHDs than driveletter should give warning'{
            Mount-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -MountAll -WarningVariable warn
            $warn.count | should be 2
        }
    }
    context -name 'Should not throw'{
        it 'valid path'{
            {mount-fsldisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx'} | should not throw
        }
    }
}