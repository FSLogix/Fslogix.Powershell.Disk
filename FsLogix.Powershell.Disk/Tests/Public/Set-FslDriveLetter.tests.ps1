$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

$Path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd'
Describe $sut {
    BeforeAll {
        mock -CommandName Get-FslAvailableDriveLetter -MockWith {
            'D'
        }
        Mock -CommandName Get-FslDisk -MockWith {
            [PSCustomObject]@{
                Name     = 'YeahRight'
                Attached = $true
            }
        }
        Mock -CommandName Get-Disk -MockWith {
            [PSCustomObject]@{
                Location = 'C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd'
                Number = 1
            }
        }
        Mock -CommandName Mount-DiskImage -MockWith {
            [PSCustomObject]@{
                Number = 1
            }
        }
        Mock -CommandName Get-diskimage -MockWith {
            [PSCustomObject]@{
                Number = 1
            }
        }
        Mock -CommandName Get-Partition -MockWith {}
        Mock -CommandName Dismount-diskimage -MockWith {}
        mock -CommandName Set-Partition -MockWith {}
    }
    Context -name 'Test input'{
        it 'pipeline input'{
            {$Path | set-fsldriveletter -letter 'D'} | should not throw
        }
        it 'positional input'{
            {Set-FslDriveletter $path 'D'} | should not throw
        }
        it 'Partition Number'{
            {Set-FslDriveletter -path $path -Letter 'D' -PartitionNumber 2} | should not throw
        }
        it 'dismount'{
            {Set-FslDriveletter -path $path -Letter 'D' -PartitionNumber 2 -Dismount} | should not throw
        }
        it 'Invalid path'{
            {set-fsldriveletter -path "C:\blah" -Letter 'D'} | should throw
        }
        it 'invalid letter' {
            {Set-Fsldriveletter -path $path -Letter "blah"} | should throw
        }
        it 'invalid partition number'{
            {Set-fsldriveletter -path $path -Letter 'D' -PartitionNumber 'blah'} | should throw
        }
    }
    Context -Name "Get-Fsldisk"{
        it 'no vhds'{
            mock -CommandName Get-fsldisk -MockWith {$null}
            {Set-FslDriveletter $path 'D'} | should throw
        }
        it 'assert mock called'{
            Assert-MockCalled -CommandName Get-Fsldisk -Times 1
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName Get-FslAvailableDriveLetter -Times 0
        }
    }
    Context -name "Letter availability"{
        it 'Letter available'{
            mock -CommandName Get-FslAvailableDriveLetter -MockWith {
                'D'
            }
            {Set-FslDriveletter $path 'D'} | should not throw
        }
        it 'Letter not available'{
            mock -CommandName Get-FslAvailableDriveLetter -MockWith {
                'E'
            }
            {Set-FslDriveletter $path 'D'} | should throw
        }
    }
    Context -name 'VHD not attached'{
        Mock -CommandName Get-FslDisk -MockWith {
            [PSCustomObject]@{
                Name     = 'YeahRight'
                Attached = $false
            }
        }
        it 'not attached'{
            {Set-FslDriveletter $path 'D'} | should not throw
        }
        it 'assert mocks called'{
            Assert-MockCalled -CommandName Mount-DiskImage -Times 1
            Assert-MockCalled -CommandName Get-DiskImage -Times 1
        }
    }
    Context -Name "partition"{
        Mock -CommandName Get-Partition -MockWith {
            Throw 'Partition'
        }
        it 'Partition error'{
            {Set-FslDriveletter $path 'D' -ErrorAction Stop} | should throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName Get-Partition -Times 1
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName Set-Partition -Times 0
        }
    }
    Context -name 'Dismount error'{
        Mock -CommandName Dismount-diskimage -MockWith {
            Throw 'Dismount'
        }
        it 'Dismount error'{
            {Set-FslDriveletter $path 'D' -ErrorAction Stop -Dismount} | should throw
        }
        it 'assert mock called'{
            Assert-MockCalled -CommandName Dismount-diskimage -Times 1
        }
    }
}