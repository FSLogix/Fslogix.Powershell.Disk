$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut{
    $Path = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"
    BeforeAll{
        Mock -CommandName Mount-DiskImage -MockWith {
            [PSCustomObject]@{
                Number = 1
            }
        }
        Mock -CommandName Get-Diskimage -MockWith {
            [PSCustomObject]@{
                Number = 1
            }
        }
        Mock -CommandName Get-partition -MockWith {
            [PSCustomObject]@{
                AccessPaths = 'D:\'
            }
        }
        mock -CommandName new-guid -MockWith {
            [PSCustomObject]@{
                Guid = 'Test'
            }
        }
        mock -CommandName New-Item -MockWith {}
        Mock -CommandName Dismount-DiskImage -MockWith {}
        mock -CommandName remove-item -MockWith {}
        Mock -CommandName Add-PartitionAccessPath -MockWith {}
    }
    Context -name 'DriveLetter mount'{
        it 'Path'{
            {Mount-fsldisk -path $Path} | should not throw
        }
        it 'passthru returns D:\'{
            $Command = MOunt-fsldisk -path $Path -PassThru
            $Command.Mount | should be 'D:\'
        }
        it 'Partition Number should be 1'{
            $Command = Mount-fsldisk -Path $Path -PassThru
            $Command.partitionnumber | should be 1
        }
        it 'assert mock called'{
            Assert-MockCalled -CommandName Mount-DiskImage -Times 1
        }
    }
    Context -name 'Guid mount'{
        Mock -CommandName Get-partition -MockWith {
            [PSCustomObject]@{
                AccessPaths = '\\?\volume{test}'
            }
        }
        it 'path'{
            {mount-fsldisk -Path $path} | should not throw
        }
        it 'returns guid'{
            $command = mount-fsldisk -path $path -PassThru
            $command.mount | should be "C:\programdata\fslogix\Guid\test"
        }
    }
    Context -name "test-input"{
        it 'Pipeline'{
            {$Path | Mount-fsldisk} | should not throw
        }
        it 'positional'{
            {Mount-fsldisk $path} | Should not throw
        }
        it 'invalid path'{
            {MOunt-fsldisk -path 'C:\blah'} | should throw
        }
    }
    Context -name "mount"{
        Mock -CommandName Mount-DiskImage -MockWith {
            Throw "Mount"
        }
        it "Mount throw"{
            {Mount-fsldisk $path -ErrorAction Stop} | should throw
        }
        it "assert script stopped"{
            Assert-MockCalled -CommandName Get-partition -Times 0
        }

        Mock -CommandName Mount-DiskImage -MockWith {
            [PSCustomObject]@{
                Number = 1
            }
        }
        it 'Assert mount called'{
            {mount-fsldisk $path} | should not throw
            Assert-MockCalled -CommandName Mount-DiskImage -Times 1
        }
    }
    Context -name "Partition"{
        Mock -CommandName Get-Partition -MockWith {
            Throw "Part"
        }
        it "Throws"{
            {Mount-fsldisk $path -ErrorAction Stop} | Should throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName get-partition -times 1
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName Dismount-DiskImage -Times 1
        }
        Mock -CommandName Get-partition -MockWith {
            [PSCustomObject]@{
                AccessPaths = 'D:\'
            }
        }
        it 'Does not throw'{
            {Mount-fsldisk $path -ErrorAction Stop} | Should not throw
        }
    }
    Context -name 'Junction path'{
        Mock -CommandName New-Item -MockWith {
            Throw 'item'
        }
        Mock -CommandName Get-partition -MockWith {
            [PSCustomObject]@{
                AccessPaths = '\\?\volume{test}'
            }
        }
        it 'Cannot create junction path'{
            {Mount-FslDisk $path -ErrorAction Stop} | should Throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName New-Item -Times 1
            Assert-MockCalled -CommandName New-Guid -Times 1
            Assert-MockCalled -CommandName Remove-item -Times 1
            Assert-MockCalled -CommandName Dismount-DiskImage -Times 1
        }

        Mock -CommandName New-Item -MockWith {}
        mock -CommandName Add-PartitionAccessPath -MockWith {
            Throw 'Partition'
        }
        it 'Partition access path'{
            {Mount-FslDisk $path -ErrorAction Stop} | should Throw
        }
        it 'does not output'{
            {Mount-FslDisk $path -passthru -ErrorAction Stop} | should Throw
            Assert-MockCalled -CommandName Dismount-DiskImage -Times 1
        }

    }
}