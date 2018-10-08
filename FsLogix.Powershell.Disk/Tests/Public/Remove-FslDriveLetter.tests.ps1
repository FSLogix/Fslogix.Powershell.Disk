$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

$Path = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"

Describe $sut{
    BeforeAll{
        Mock -CommandName Get-FslDisk -MockWith {
            [PSCustomObject]@{
                Attached = $true
            }
        }
        mock -CommandName Get-Disk -MockWith {
            [PSCustomObject]@{
                Location = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"
                Number = 1
                PartitionNumber = 1
            }
        }
        mock -CommandName Mount-DiskImage -MockWith {
            [PSCustomObject]@{
                Number = 1
            }
        }
        Mock -CommandName Get-Partition -MockWith {
            [PSCustomObject]@{
                AccessPaths = 'D:\'
                Number = 1
            }
        }
        Mock -CommandName Get-Volume -MockWith {
            [PSCustomObject]@{
                DriveLetter = 'D:\'
                PartitionNumber = 1
                Number = 1
            }
        }
        Mock -CommandName Get-Diskimage -MockWith {
            [PSCustomObject]@{
                Number = 1
            }
        }
        mock -CommandName Remove-PartitionAccessPath -MockWith{}
        Mock -CommandName Dismount-DiskImage -MockWith {}
    }
    Context -Name "test input"{
        it 'Accepts pipeline'{
            {$Path | Remove-FslDriveLetter} | should not throw
        }
        it 'Accepts Positional'{
            {Remove-FslDriveLetter $path} | should not throw
        }
        it 'invalid path'{
            {Remove-FslDriveLetter -Path "C:\blah"} | should throw
        }
    }
    Context -name "Attached"{
        it 'VHD Attached'{
            {Remove-FslDriveLetter -Path $Path} | should not throw
        }
        it 'assert mocks called'{
            Assert-MockCalled -CommandName Get-disk -Times 1
        }
        it 'assert mock was not called'{
            Assert-MockCalled -commandName Mount-DiskImage -Times 0
        }
    }
    Context -name "Not attached"{
        Mock -CommandName Get-FslDisk -MockWith {
            [PSCustomObject]@{
                Attached = $false
            }
        }
        
        mock -CommandName Mount-DiskImage -MockWith {
            Throw 'mount'
        }
        
        it 'Mount error'{
            {Remove-FslDriveLetter -Path $Path -ErrorAction Stop} | should throw
        }

        it 'Assert script stopped'{
            Assert-MockCalled -CommandName Get-Partition -Times 0
        }

        mock -CommandName Mount-DiskImage -MockWith {
            [PSCustomObject]@{
                Number = 1
            }
        }

        it 'VHD not attached'{
            {Remove-FslDriveLetter -Path $Path} | should not throw
        }
        it 'assert mocks called'{
            Assert-MockCalled -CommandName Get-disk -Times 0
        }
        it 'assert mock was not called'{
            Assert-MockCalled -commandName Mount-DiskImage -Times 1
        }
    }
    Context -Name "Returned invalid DriveLetter"{
        Mock -CommandName Get-Partition -MockWith {
            [PSCustomObject]@{
                AccessPaths = "\\?\Volume{Test}"
                Number = 1
            }
        }
        it '\\?\Volume{Test}'{
            {Remove-FslDriveLetter -Path $Path -ErrorAction Stop} | should throw
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName Get-volume -times 0
        }
        Mock -CommandName Get-Partition -MockWith {
            [PSCustomObject]@{
                AccessPaths = $null
                Number = 1
            }
        }
        it 'null'{
            {Remove-FslDriveLetter -Path $Path -ErrorAction Stop} | should throw
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName Get-volume -times 0
        }
    }
    Context -name "Get-Volume"{
        Mock -CommandName Get-Volume -MockWith {
            Throw 'Volume'
        }
        it 'Volume'{
            {Remove-FslDriveLetter -Path $Path -ErrorAction Stop} | should throw
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName Remove-PartitionAccessPath -times 0
        }
    }
    Context -name "Remove-PartitionAccessPath"{
        Mock -CommandName Remove-PartitionAccessPath -MockWith {
            Throw 'AccessPath'
        }
        it 'AccessPath'{
            {Remove-FslDriveLetter -Path $Path -ErrorAction Stop} | should throw
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName Dismount-DiskImage -times 0
        }
    }
    Context -Name "Dismount"{
        Mock -CommandName Dismount-DiskImage -MockWith {
            Throw 'Dismount'
        }
        it 'Dismount'{
            {Remove-FslDriveLetter -Path $Path -ErrorAction Stop -dismount} | should throw
        }
    }
    Context -Name "Partition Number"{
        it 'number'{
            {Remove-FslDriveLetter -Path $Path -PartitionNumber 2} | should not throw
        }
    }
}