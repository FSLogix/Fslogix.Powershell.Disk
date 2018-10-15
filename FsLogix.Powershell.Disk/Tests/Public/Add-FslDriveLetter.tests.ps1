$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut {

    $Script:FslDisk = [PSCustomObject]@{
        Attached = $true
        Number = 1
    }
    $Script:Disk = [PSCustomObject]@{
        Number = 1
    }
    $Script:DiskImage = [PSCustomObject]@{
        Number = 1
    }
    $Script:MountImage =  [PSCustomObject]@{
        Number = 1
    }

    $Script:TestInput = [PSCustomObject]@{
        Path = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"
        PartitionNumber = 1
    }
    $Script:Path = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"
    $Script:PartitionNumber = 1

    BeforeAll{
        mock -CommandName Get-FslDisk -MockWith {
            $Script:FslDisk
        }
        Mock -CommandName Get-Disk -MockWith {
            $Script:Disk
        }
        Mock -CommandName Get-Diskimage -MockWith{
            $Script:DiskImage
        }
        Mock -CommandName Mount-diskimage -MockWith {
            $Script:MountImage
        }
        mock -CommandName Set-Partition -MockWith {}
        Mock -CommandName Dismount-DiskImage -MockWith {}
    }
    Context -name 'Valid Input'{
        
        $Error.clear()
        
        it "Normal Input"{
            {Add-FslDriveLetter -path $path} | should not throw
        }
        it 'Accepts positional pipeline'{
            {$Path | Add-FslDriveLetter } | should not throw
        }
        it 'Accepts multiple pipelinese by property name'{
            {$TestInput | Add-FslDriveLetter} | should not throw
        }
        it 'Positional parameter'{
            {Add-FslDriveLetter $Path $PartitionNumber} | should not throw
        }
        it 'Switch parameters'{
            {Add-FslDriveLetter $Path -Dismount -Passthru} | should not throw
        }
        it "Did not add to error variable"{
            $Error.Count | should be 0
        }
    }
    Context -name 'Set-Partition'{
        $Error.Clear()
        Mock -CommandName Set-partition -MockWith {
            Throw 'Set'
        }
        it 'Assign fails'{
            {Add-FslDriveLetter -path $path -dismount -Passthru} | should throw
        }
        it 'Assert Mock was called'{
            Assert-MockCalled -CommandName Set-Partition -Times 1
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName Dismount-DiskImage -Times 0
        }
        it 'Validate Error Count'{
            ## The Set-Partition will continue to loop until letter = 'C
            $Error.count | should be 24
        }
    }
    Context 'Attached Disk'{
        $Script:FslDisk = [PSCustomObject]@{
            Attached = $false
            Number = 1
        }
        mock -CommandName Get-FslDisk -MockWith {
            $Script:FslDisk
        }
        $Error.clear()

        it "Disk is not mounted, should mount"{
            {Add-FslDriveLetter -path $path} | should not throw
            Assert-MockCalled -CommandName Mount-diskimage -Times 1
        }
        it 'Get-Disk should not be called'{
            Assert-MockCalled -CommandName Get-Disk -Times 0
        }
        it 'Assert Script did not stop'{
            Assert-MockCalled -CommandName Set-Partition -Times 1
        }
        it 'passthru should be z'{
            $command = Add-FslDriveLetter -Path $path -passthru
            $command | should be 'Z:\'
        }
        it "Did not add to error variable"{
            $Error.Count | should be 0
        }
    }
    Context 'Non-Attached Disk'{

        $Error.clear()

        it 'Valid inputs does not throw'{
            {Add-FslDriveLetter -path $path} | should not throw
        }
        it 'Assert mocks were called'{
            Assert-MockCalled -CommandName Mount-DiskImage -Times 1
            Assert-MockCalled -CommandName Get-Diskimage -Times 1
        }
        it 'passthru should be z'{
            $command = Add-FslDriveLetter -Path $path -passthru
            $command | should be 'Z:\'
        }
        it "Did not add to error variable"{
            $Error.Count | should be 0
        }
    }
    Context -Name "Dismount"{
        $Error.Clear()
        it 'Valid inputs should not throw'{
            {Add-FslDriveLetter -path $path -Dismount} | should not throw
        }
        it 'throws'{
            mock -CommandName Dismount-DiskImage -MockWith {
                Throw 'Dismount'
            }
            {Add-FslDriveLetter -path $path -Dismount -ErrorAction Stop} | should throw
        }
        it "assert mock was called"{
            Assert-MockCalled -CommandName Dismount-DiskImage -Times 1
        }
        it "Validate Error Count"{
            $Error.count | should be 2
        }
    }
}