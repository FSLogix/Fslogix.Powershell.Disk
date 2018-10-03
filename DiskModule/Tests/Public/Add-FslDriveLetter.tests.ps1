$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut {

    $Path = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"

    BeforeAll{
        mock -CommandName Get-FslDisk -MockWith {
            [PSCustomObject]@{
                Attached = $true
                Number = 1
            }
        }
        Mock -CommandName Get-Disk -MockWith {
            [PSCustomObject]@{
                Number = 1
            }
        }
        Mock -CommandName Get-Diskimage -MockWith{
            [PSCustomObject]@{
                Number = 1
            }
        }
        Mock -CommandName Mount-diskimage -MockWith {
            [PSCustomObject]@{
                Number = 1
            }
        }
        Mock -CommandName Get-Partition -MockWith {}
        mock -CommandName Set-Partition -MockWith {}
        Mock -CommandName Dismount-DiskImage -MockWith {}
    }
    Context 'Attached Disk'{
        it 'Valid inputs does not throw'{
            {Add-FslDriveLetter -path $path} | should not throw
        }
        it 'Assert mocks were called'{
            Assert-MockCalled -CommandName Get-Disk -Times 1
            Assert-MockCalled -CommandName Get-Partition -Times 1
        }
        it 'passthru should be z'{
            $command = Add-FslDriveLetter -Path $path -passthru
            $command | should be 'Z:\'
        }
    }
    Context 'Non-Attached Disk'{
        mock -CommandName Get-FslDisk -MockWith {
            [PSCustomObject]@{
                Attached = $false
                Number = 1
            }
        }
        it 'Valid inputs does not throw'{
            {Add-FslDriveLetter -path $path} | should not throw
        }
        it 'Assert mocks were called'{
            Assert-MockCalled -CommandName Mount-DiskImage -Times 1
            Assert-MockCalled -CommandName Get-Diskimage -Times 1
            Assert-MockCalled -CommandName Get-Partition -Times 1
        }
        it 'passthru should be z'{
            $command = Add-FslDriveLetter -Path $path -passthru
            $command | should be 'Z:\'
        }
    }
    Context -Name "Partition"{
        Mock -CommandName Get-Partition -MockWith {
            Throw "partition"
        }
        it 'Partition fails'{
            {Add-FslDriveLetter -path $path -ErrorAction Stop} | should throw
        }
        it 'assert partiton was called'{
            Assert-MockCalled -CommandName Get-Partition -Times 1
        }
        it "Partition Number"{
            Mock -CommandName Get-Partition -MockWith {}
            {Add-FslDriveLetter -path $path -Dismount -PartitionNumber 1} | should not throw
        }
        <#it 'Fails to assign driveletter'{
            Mock -CommandName Get-Partition -MockWith {}
            Mock -CommandName Set-Partition -MockWith {
                Throw "Partition"
            }
            {Add-FslDriveLetter -path $path -ErrorAction Stop} | should throw
        }#>
    }
    Context -Name "Dismount"{
        it 'Valid inputs should not throw'{
            {Add-FslDriveLetter -path $path -Dismount} | should not throw
        }
        it 'throws'{
            mock -CommandName Dismount-DiskImage -MockWith {
                Throw 'Dismount'
            }
            {Add-FslDriveLetter -path $path -Dismount -ErrorAction Stop} | should throw
        }
    }
}