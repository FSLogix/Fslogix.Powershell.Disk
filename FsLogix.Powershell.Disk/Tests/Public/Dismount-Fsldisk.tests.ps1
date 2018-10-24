$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut {

    $Script:Path = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"
    $Script:DiskNumber = 1

    BeforeAll {
        Mock -CommandName Get-Disk -MockWith {}
        Mock -CommandName Get-Partition -MockWith {}
        mock -CommandName Remove-PartitionAccessPath -MockWith {}
        mock -CommandName Remove-Item -MockWith {}
        mock -CommandName Dismount-diskimage -MockWith {}
        mock -CommandName Get-FslDisk -MockWith {}
    }
    Context -Name 'Get-FslDisk'{
        $Error.Clear()
        Mock -CommandName Get-Fsldisk -MockWith {
            Throw 'Disk'
        }
        Mock -CommandName Get-Disk -MockWith {
            [PSCustomObject]@{
                Location = $Script:Path
            }
        }
        it 'Should throw'{
            {Dismount-FslDisk -DiskNumber $Script:DiskNumber -ErrorAction Stop} | should throw
        }
        it 'Assert error was called'{
            $Error.count | should be 2
        }
        it 'Mock should be called'{
            Assert-MockCalled -CommandName Get-fsldisk -Times 1
        }
        it 'Assert script stopped'{
            Assert-MockCalled -CommandName Get-Partition -Times 0
        }
    }
    Context -Name "Throws" {
        it 'invalid path' {
            {Dismount-fsldisk -path 'C:\blah'} | should throw
        }
        it 'Assert Script stops' {
            Assert-Mockcalled -CommandName Get-Disk -Times 0
        }
        it 'No Path Disk returned' {
            {Dismount-FslDisk -Path $Path} | should throw
        }
        it 'No DiskNumber disk returned' {
            {Dismount-FslDisk -DiskNumber $DiskNumber } | should throw
        }
    }
    Context -Name "Junction point removal mock" {
        mock -CommandName Get-Disk -MockWith {
            [PSCustomObject]@{
                Location   = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"
                Number = $DiskNumber
            }
        }
        mock -CommandName Get-Partition -MockWith {
            [PSCustomObject]@{
                AccessPaths = 'C:\programdata\fslogix\guid\test'
            }
        }
        mock -CommandName Remove-PartitionAccessPath -MockWith {
            Throw "Partition access path"
        }
        
        it 'Throws with path' {
            {Dismount-fsldisk -path $path -ErrorAction Stop} | should throw
        }
        it 'Throws with DiskNumber'{
            {Dismount-fsldisk -DiskNumber $DiskNumber -ErrorAction Stop} | should throw
        }
        it 'assert script stops.'{
            Assert-MockCalled -CommandName Remove-item -Times 0
            Assert-MockCalled -CommandName Dismount-DiskImage -Times 0
        }
    }
    Context -Name "Remove-Item fails"{
        mock -CommandName Get-Disk -MockWith {
            [PSCustomObject]@{
                Location   = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"
                Number = $DiskNumber
            }
        }
        mock -CommandName Get-Partition -MockWith {
            [PSCustomObject]@{
                AccessPaths = 'C:\programdata\fslogix\guid\test'
            }
        }
        Mock -CommandName Remove-Item -MockWith {
            Throw "Remove-Item"
        }
        it 'Throws with path' {
            {Dismount-fsldisk -path $path -ErrorAction Stop} | should throw
        }
        it 'Throws with DiskNumber'{
            {Dismount-fsldisk -DiskNumber $DiskNumber -ErrorAction Stop} | should throw
        }
        it 'assert script stops.'{
            Assert-MockCalled -CommandName Dismount-DiskImage -Times 0
        }
    }
    Context -Name "Dismount-Diskimage fails"{
        mock -CommandName Get-Disk -MockWith {
            [PSCustomObject]@{
                Location   = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"
                Number = $DiskNumber
            }
        }
        mock -CommandName Get-Partition -MockWith {
            [PSCustomObject]@{
                AccessPaths = 'C:\programdata\fslogix\guid\test'
            }
        }
        Mock -CommandName Dismount-Diskimage -MockWith {
            Throw "Dismount"
        }
        it 'Throws with path' {
            {Dismount-fsldisk -path $path -ErrorAction Stop} | should throw
        }
        it 'Throws with DiskNumber'{
            {Dismount-fsldisk -DiskNumber $DiskNumber -ErrorAction Stop} | should throw
        }
    }
    Context -Name "All is good!"{
        mock -CommandName Get-Disk -MockWith {
            [PSCustomObject]@{
                Location   = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"
                Number = $DiskNumber
            }
        }
        mock -CommandName Get-Partition -MockWith {
            [PSCustomObject]@{
                AccessPaths = 'C:\programdata\fslogix\guid\test'
            }
        }
        it 'Path does not throw'{
            {Dismount-fsldisk -path $path} | should not throw
        }
        it 'DiskNumber does not throw'{
            {Dismount-fsldisk -DiskNumber $DiskNumber} | should not throw
        }
        it 'Assert all mocks were called'{
            Assert-MockCalled -CommandName Get-Disk -Times 1
            Assert-MockCalled -CommandName Get-Partition -Times 1
            Assert-MockCalled -CommandName Remove-PartitionAccessPath 1
            Assert-MockCalled -CommandName Remove-Item -Times 1
            Assert-MockCalled -CommandName Dismount-DiskImage -Times 1
        }
        it 'PartitionNumber'{
            {Dismount-fsldisk -DiskNumber $DiskNumber -PartitionNumber 1} | should not throw
        }
    }
}