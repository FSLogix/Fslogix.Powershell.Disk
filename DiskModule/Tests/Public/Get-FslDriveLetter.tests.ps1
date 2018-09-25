$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut {
    $Path = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"
    BeforeAll{
        Mock -CommandName Get-FslDisk -MockWith {
            [PSCustomObject]@{
                Attached = $false
                Name = "Yeahright.vhd"
            }
        }
        Mock -CommandName Get-Disk -MockWith {
            [PSCustomObject]@{
                Location = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"
                Number = 1
            }
        }
        Mock -CommandName Get-DiskImage -MockWith {
            [PSCustomObject]@{
                Number = 1
            }
        }
        Mock -CommandName Mount-DiskImage -MockWith{
            [PSCustomObject]@{
                Number = 1
            }
        }
        Mock -CommandName Get-Partition -MockWith {}
        Mock -CommandName Dismount-DiskImage -MockWith {}
    }
    
    Context -name "Path throws"{
        it 'invalid path'{
            {Get-FslDriveletter -path "C:\blah"} | should throw
        }
    }
    Context -name "Returns invalid, warning message for no valid DriveLetter"{
        Mock -CommandName Get-Partition -MockWith {
            [PSCustomObject]@{
                Accesspaths = "test\\?\volume{test}"
            }
        }
        it 'Attached'{
            Mock -CommandName Get-FslDisk -MockWith {
                [PSCustomObject]@{
                    Attached = $True
                    Name = "Yeahright.vhd"
                }
            }
            {Get-FslDriveletter -path $path} | should not throw
        }
        it 'Assert Get-Disk was called'{
            Assert-MockCalled -CommandName Get-Disk -Times 1
        }
        it 'Not attached'{
            Mock -CommandName Get-FslDisk -MockWith {
                [PSCustomObject]@{
                    Attached = $false
                    Name = "Yeahright.vhd"
                }
            }
            {Get-FslDriveletter -path $path} | should not throw
        }
        it 'Assert Mount-Diskimage was called'{
            Assert-MockCalled -CommandName Mount-DiskImage -Times 1
        }
    }
    Context -Name "Returns Drive Letter"{
        Mock -CommandName Get-Partition -MockWith {
            [PSCustomObject]@{
                Accesspaths = "D:\"
            }
        }
        it 'Returns D:\'{
            $DriveLetter = Get-FslDriveletter -path $path
            $DriveLetter | should be "D:\"
        }
    }
    Context -Name "Dismount"{
        
        it "Dismount switch"{
            {Get-FslDriveletter -path $path -Dismount} | should not throw
        }
        it "Assert dismount was called"{
            Assert-MockCalled -CommandName Dismount-DiskImage -Times 1
        }
        Mock -CommandName Dismount-DiskImage -MockWith {
            Throw "Dismount fails"
        }
        it 'Dismount throws'{
            {Get-FslDriveletter -path $path -Dismount -ErrorAction Stop} | should throw
        }
        it 'Assert dismount was called'{
            Assert-MockCalled -CommandName Dismount-DiskImage -Times 1
        }
    }
    Context -name "Mount"{
        Mock -CommandName Get-FslDisk -MockWith {
            [PSCustomObject]@{
                Attached = $false
                Name = "Yeahright.vhd"
            }
        }
        Mock -CommandName Mount-DiskImage -MockWith {
            Throw "Mount failed"
        }
        it "Mount throws"{
            {Get-FslDriveletter -path $path -ErrorAction Stop} | Should throw
        }
        it "Assert script stopped"{
            Assert-MockCalled -CommandName Get-Partition -Times 0
        }
    }

}