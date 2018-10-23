$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut{

    $Script:DriveLetter = "D:\"
    $Script:Path = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\FsLTest.vhdx"
    $Script:TestDisk = [PSCustomObject]@{
        Attached = $true
        Name     = "Test"
        Extension = ".vhd"
    }
    $Script:TestGetDisk = [PSCustomObject]@{
        Location = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\FsLTest.vhdx"
        Number = 1
    }
    $Script:TestMount = [PSCustomObject]@{
        DiskNumber = 1
    }
    $Script:TestMaxSize = [PSCustomObject]@{
        SizeMax = 100
    }
    BeforeAll{
        Mock -CommandName Get-FslDriveletter -MockWith {
            $Script:DriveLetter
        }
        Mock -CommandName Get-FslDisk -MockWith {
            $Script:TestDisk
        }
        mock -CommandName Add-FslDriveLetter -MockWith {
            $Script:DriveLetter
        }
        Mock -CommandName Get-Disk -MockWith {
            $Script:TestGetDisk
        }
        Mock -CommandName Mount-FslDisk -MockWith {
            $Script:TestMount
        }
        Mock -CommandName Get-PartitionSupportedSize -MockWith {
            $Script:TestMaxSize
        }
        Mock -CommandName Resize-Vhd -mockwith {}
        Mock -CommandName Resize-Partition -MockWith {}
        Mock -CommandName Set-Volume -MockWith {}
        Mock -CommandName Dismount-DiskImage -MockWith {}
        Mock -CommandName Rename-item -MockWith {}
        Mock -CommandName Dismount-fsldisk -MockWith {}
        Mock -CommandName Set-FslLabel -MockWith {}
    }
    Context -Name "General Throws"{
        it 'Invalid path'{
            {Set-Fsldisk -path "C:\blah"} | should throw
        }
        it 'Is not a VHD'{
            Mock -CommandName Get-Fsldisk -MockWith {
                Throw "Not a vhd"
            }
            {Set-Fsldisk -path "C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\DiskModule\Functions\Public\Set-FslDisk.ps1" -ErrorAction Stop} | should throw
        }
    }

    Context -name 'Set-FslLabel'{
        Mock -CommandName Set-FslLabel -MockWith {
            Throw 'label'
        }
        it 'throws'{
            {Set-Fsldisk -path $path -Label "test" -Assign -ErrorAction Stop} | should throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName Set-fsllabel -Times 1
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName Add-FslDriveLetter -Times 0
        }
    }
    Context -Name 'Assign'{
        Mock -CommandName Add-FslDriveletter -MockWith {
            Throw 'Letter'
        }
        it 'Throws'{
            {Set-Fsldisk -path $path -Label "test" -Assign -ErrorAction Stop} | should throw
        }
        it 'asserts mock'{
            Assert-MockCalled -CommandName Add-FslDriveletter -Times 1
        }
    }

    Context -Name "DriveLetter"{
        it 'If returned null, assign parameter'{
            Mock -CommandName Get-FslDriveLetter -MockWith {$Null}
            {Set-Fsldisk -path $Path -Label "Daniel" -Assign} | should not throw
        }

        it 'Returns valid Driveletter, does not throw'{
            Mock -CommandName Get-Fsldriveletter -MockWith {
                "D:\"
            }
            {Set-Fsldisk -path $Path -Label "Daniel"} | should not throw
        }
        it 'Assert mocks called'{
            Assert-MockCalled -CommandName Set-FslLabel -Times 2
        }
    }
    Context -name "Rename"{
        it 'rename'{
            {Set-Fsldisk -Path $Path -Name "Daniel.vhd"} | should not throw
        }
        it 'no extension, should generate one and not throw'{
            {Set-Fsldisk -Path $Path -Name "Daniel"} | should not throw
        }
        it 'Different extensions should throw'{
            {Set-Fsldisk -Path $Path -Name "Daniel.vhdx"} | should throw
        }

        it "Dismount fails"{
            Mock -CommandName Dismount-DiskImage -MockWith{
                Throw "Dismount"
            }
            {Set-Fsldisk -path $Path -Name "Kim_S-0-2-26-1996" -ErrorAction Stop} | should throw
        }

        Mock -CommandName Dismount-DiskImage -MockWith {}

        it "Assert mock called"{
            Assert-MockCalled -CommandName Rename-item -Times 1
        }
        
        it "Rename fails"{
            Mock -CommandName Rename-item -MockWith {
                Throw "Rename"
            }
            {Set-Fsldisk -path $Path -Name "Kim_S-0-2-26-1996" -ErrorAction Stop} | should throw
        }
    }

    Context -name "Size input"{
        it 'Accepts normal input'{
            {Set-Fsldisk -path $Path -size 1gb} | should not throw
        }
        it 'Accepts pipeline input'{
            {$Path | set-fsldisk -size 1gb} | should not throw
        }
    }
    Context -name "Resize-VHD"{
        Mock -CommandName Resize-VHD -MockWith {
            Throw 'VHD'
        }
        $Error.clear()
        it 'Throws'{
            {Set-Fsldisk -path $Path -size 1gb -ErrorAction Stop} | should throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName Resize-VHD -Times 1
        }
        it 'Error was thrown'{
            $Error.Count | should be 2
        }
        it "assert script stopped"{
            Assert-MockCalled -CommandName Resize-Partition -Times 0
        }
    }

    Context -name "Size variance"{
        it "Attached should call Get-Disk"{
            $Script:TestDisk = [PSCustomObject]@{
                Attached = $true
                Name     = "Test"
            }
            Mock -CommandName Get-FslDisk -MockWith {
                $Script:TestDisk
            }
            {Set-Fsldisk -path $Path -size 1gb} | should not throw
            Assert-MockCalled -CommandName Get-Disk -Times 1
        }
        it "Not attached should call Mount-FslDisk"{
            $Script:TestDisk = [PSCustomObject]@{
                Attached = $false
                Name     = "Test"
            }
            Mock -CommandName Get-FslDisk -MockWith {
                $Script:TestDisk
            }
            {Set-Fsldisk -path $Path -size 1gb} | should not throw
            Assert-MockCalled -CommandName Mount-FslDisk -Times 1
        }
    }
    Context -name "Get-PartitionSupportedSize"{
        Mock -CommandName Get-PartitionSupportedSize -MockWith {
            Throw 'Size'
        }
        $Error.clear()
        it 'Throws'{
            {Set-Fsldisk -path $Path -size 1gb -ErrorAction Stop} | should throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName Get-PartitionSupportedSize -Times 1
        }
        it 'Error was thrown'{
            $Error.Count | should be 2
        }
        it "assert script stopped"{
            Assert-MockCalled -CommandName Resize-Partition -Times 0
        }
    }
    Context -name "Resize-Partition"{
        Mock -CommandName Resize-Partition -MockWith {
            Throw 'resize'
        }
        $Error.clear()
        it 'Throws'{
            {Set-Fsldisk -path $Path -size 1gb -Dismount -ErrorAction Stop} | should throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName Resize-Partition -Times 1
        }
        it 'Error was thrown'{
            $Error.Count | should be 2
        }
        it "assert script stopped"{
            Assert-MockCalled -CommandName Dismount-fsldisk -Times 0
        }
    }
    Context -name "Dismount"{
        it 'No dismount switch should not call dismount'{
            {Set-Fsldisk -path $Path -size 1gb } | should not throw
            Assert-MockCalled -CommandName Dismount-fsldisk -Times 0
        }
        it 'Calls dismount'{
            {Set-Fsldisk -path $Path -size 1gb -Dismount} | should not throw
            Assert-MockCalled -CommandName Dismount-fsldisk -Times 1
        }
        it 'Throws'{
            Mock -CommandName Dismount-fsldisk -MockWith {
                Throw 'Dismount'
            }
            {Set-Fsldisk -path $Path -size 1gb -Dismount -ErrorAction Stop} | should throw
        }
    }
    Context -Name "Future Tests"{
        
    }
}