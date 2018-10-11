$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

$Path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\FsLTest.vhdx'
Mount-DiskImage $Path -ErrorAction SilentlyContinue
$DiskNumber = 1
$PartitionNumber = 1
$label = "Daniel"
Describe $sut {
    BeforeAll{
        Mock -CommandName Mount-fsldisk -MockWith {
            [PSCustomObject]@{
                DiskNumber = 1
                PartitionNumber = 1
            }
        }
        Mock -CommandName Set-Volume -MockWith {}
        Mock -CommandName Dismount-fsldisk -MockWith {}
    }
    Context -name "Mount Mock"{
        Mock -CommandName Mount-fsldisk -MockWith {
            Throw 'Mock'
        }
        it 'Throws'{
            {Set-FslLabel -Path $path -Label $label -ErrorAction Stop} | should throw
        }
        it 'assert mock called'{
            Assert-MockCalled -CommandName Mount-FslDisk -Times 1
        }
    }
    Context -name "Partition Mock"{
        Mock -CommandName Get-Partition -MockWith {
            Throw 'Partition'
        }
        it 'Throws'{
            {Set-FslLabel -Path $path -Label $label -ErrorAction Stop} | should throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName Get-partition -Times 1
        }
    }
    Context -name 'Volume Mock'{
        Mock -CommandName Get-Volume -MockWith {
            Throw 'Volume'
        }
        it 'Throws'{
            {Set-FslLabel -Path $path -Label $label -ErrorAction Stop} | should throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName Get-Volume -Times 1
        }
    }
    Context -name 'Dismount mock'{
        Mock -CommandName Dismount-FslDisk -MockWith {
            Throw 'Dismount'
        }
        it 'Path Throws'{
            {Set-FslLabel -Path $path -Label $label -Dismount -ErrorAction Stop} | should throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName Dismount-FslDisk -Times 1
        }
        it 'Number throws'{
            {Set-FslLabel -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -Label $label -Dismount -ErrorAction Stop} | should throw
        }
        it 'assert mock called'{
            Assert-MockCalled -CommandName Dismount-fsldisk -Times 2
        }
    }
    Context -name 'Input'{
        it 'Path'{
            {Set-FslLabel -path $Path -Label $label} | should not throw
        }
        it 'Path positional'{
            {Set-FslLabel $Path -Label $label} | should not throw
        }
        it 'Pipeline'{
            {$Path | set-FslLabel -Label $label} | should not throw
        }
        it 'DiskNumber and PartitionNumber'{
            {Set-Fsllabel -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -Label $label} | should not throw
        }
        it 'positional'{
            {Set-Fsllabel $DiskNumber $PartitionNumber -Label $label} | should not throw
        }
        it 'disknumber pipeline'{
            {$DiskNumber | set-fsllabel -PartitionNumber $PartitionNumber -Label $label } |should not throw
        }
        it 'PartitionNumber pipeline'{
            {$PartitionNumber | set-fsllabel -DiskNumber $DiskNumber -Label $label } |should not throw
        }

        it 'Empty Path should throw'{
            {Set-FslLabel -path "" -Label $label} | should throw
        }
        it 'empty label should throw'{
            {Set-fsllabel -path $Path -Label ""} | should throw
        }
        it 'dismount'{
            {Set-Fsllabel $path -Label $label -Dismount} | should not throw
        }
    }
}