$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut{

    $Path = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\FsLTest.vhdx"

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
    Context -Name 'Add-FslDriveletter'{
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
            {Set-Fsldisk -Path $Path -Name "Daniel"} | should not throw
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

    Context -Name "Future Tests"{
        
    }
}