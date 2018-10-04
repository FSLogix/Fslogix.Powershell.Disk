$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut{

    $Path = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\Test1 - Copy - Copy.vhd"

    BeforeAll{
        Mock -CommandName Get-FslDriveletter -MockWith {
            "D:\"
        }
        Mock -CommandName Get-FslDisk -MockWith {
            [PSCustomObject]@{
                Attached    = $true
                Name        = "Test"
            }
        }
        Mock -CommandName Set-Volume -MockWith {}
        Mock -CommandName Dismount-DiskImage -MockWith {}
        Mock -CommandName Rename-item -MockWith {}
        mock -CommandName Add-FslDriveLetter -MockWith {
            "D:\"
        }
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
    Context -Name "DriveLetter"{
        it 'Returns a null DriveLetter, should throw'{
            Mock -CommandName Get-FslDriveLetter -MockWith {$Null}
            {Set-Fsldisk -path $Path -Label "Daniel"} | should throw
        }
        it 'Assert script stopped'{
            Assert-MockCalled -CommandName Set-Volume -times 0
        }
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
            Assert-MockCalled -CommandName Get-Fsldriveletter -times 1
            Assert-MockCalled -CommandName Set-volume -Times 1
        }
        it 'Set Volume Fails'{
            Mock -CommandName Set-volume -MockWith { 
                Throw "Fail"
            }
            {Set-Fsldisk -path $Path -Label "Daniel" -ErrorAction Stop} | should throw
        }
    }
    Context -name "Rename"{
        it 'Does not match Regex'{
            {Set-Fsldisk -path $Path -Name 'blah'} | should throw
        }
        it "assert script stopped"{
            Assert-MockCalled -CommandName Rename-item -Times 0
        }
        it "Dismount fails"{
            Mock -CommandName Dismount-DiskImage -MockWith{
                Throw "Dismount"
            }
            {Set-Fsldisk -path $Path -Name "Kim_S-0-2-26-1996" -ErrorAction Stop} | should throw
        }

        Mock -CommandName Dismount-DiskImage -MockWith {}

        it "Assert script stops"{
            Assert-MockCalled -CommandName rename-item -times 0
        }
        it 'Does not match original, but maches flipflop'{
            {Set-Fsldisk -path $Path -Name "S-0-2-26-1996_Kim"} | should not throw
        }
        it "Matches original"{
            {Set-Fsldisk -path $Path -Name "Kim_S-0-2-26-1996"} | should not throw
        }
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

    Context -Name "Future Tests"{
        
    }
}