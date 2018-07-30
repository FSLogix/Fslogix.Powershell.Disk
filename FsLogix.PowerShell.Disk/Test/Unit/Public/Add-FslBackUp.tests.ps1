$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$DIR = 'C:\Users\danie\Documents\VHDModuleProject'

Describe $sut {
    BeforeAll {
        Mock -CommandName New-FslDisk -MockWith {} -Verifiable
        Mock -CommandName Copy-FslToDisk -MockWith {$true} -Verifiable
    }
    context -Name 'Should throw' {
        it 'Destination is invalid' {
            {Add-FslBackup -Destination 'C:\blah' -Directory $DIR} | should throw
        }
        it 'Directory is invalid should give one error' {
            Add-FslBackUp -Directory 'C:\blah' -ErrorVariable Error 
            $Error.count | should be 1
        }
        it 'Copy failed, because of size or whatever reason' {
            mock -CommandName Copy-FslToDisk -MockWith {throw}
            Add-FslBackUp -Directory $DIR -ErrorVariable Error
            $Error.Count -gt 0 | should be $true
        }
    }
    context -name 'Should not throw' {
        BeforeEach{
            mock -CommandName get-childitem -MockWith {
                return 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit\Public'
            }
        }
        it 'No input, use defaults' {
            {add-fslbackup} | should not throw
        }
        it 'Valid input' {
            {Add-FslBackUp -Directory $DIR} | should not throw
        }
        it 'VHD' {
            {Add-FslBackUp -Directory $DIR -VHD} | should not throw
        }
        it 'VHDx' {
            {Add-FslBackUp -Directory $DIR -VHDx} | should not throw
        }
        it 'Destination' {
            {Add-FslBackUp -Destination 'C:\Users\danie\Documents\VHDModuleProject' -Directory $DIR} | should not throw
        }
        it 'name' {
            {Add-FslBackUp -VHDName 'hi.vhd' -Directory $DIR} | should not throw
        }
    }
    Context -name 'Test' {
        it 'Accepts pipeline input' {
            {"test"|Add-FslBackUp} | should be $true
        }
        it 'Assert the mock is called' {
            Assert-VerifiableMocks
        }
        it 'prints some verbose lines' {
            $verbose = Add-FslBackUp -Verbose 4>&1
            $verbose.count -gt 0 | should be $true
        }
    }
}