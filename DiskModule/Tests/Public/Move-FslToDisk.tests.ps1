$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut{

    $VHD = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"
    $Path = "C:\Users\danie\Documents\VHDModuleProject\sandbox.1.ps1"
    $Destination = "Test"
    BeforeAll {
        Mock -CommandName Mount-FslDisk -MockWith {
            [PSCustomObject]@{
                Mount = 'C:\'
                DiskNumber = 1
            }
        }
        Mock -CommandName Move-Item -MockWith {}
        Mock -CommandName Dismount-FslDisk -MockWith {}
    }

    Context -name "Throw"{
        it 'Invalid Path'{
            {Move-FslToDisk -VHD $VHD -Path 'C:\blah' -Destination $Destination} | should throw
        }
    }

    Context -Name "Mount-FslDisk Fails"{
        Mock -CommandName Mount-FslDisk -MockWith{
            Throw "Failed Mount"
        }
        it 'Mount fails'{
            {Move-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -dismount -ErrorAction Stop} | should throw
        }
        it 'Does not continue script' {
            Assert-MockCalled -CommandName Dismount-FslDisk -Times 0
            Assert-MockCalled -CommandName Move-Item -Times 0
        }
    }

    Context -name "Move-Item fails"{
        Mock -CommandName Move-Item -MockWith {
            Throw 'Cannot Move'
        }
        it 'Move-item throws'{
            {Move-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -ErrorAction Stop} | should throw
        }
        it "Script stops, dismount won't be called."{
            {Move-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -ErrorAction Stop -Dismount} | should throw
        }
        It 'Dismounts' {
            Assert-MockCalled -CommandName Dismount-FslDisk -Times 2
        }  
    }
    Context -name "Dismount fails"{
        Mock -CommandName Dismount-FslDisk -MockWith {
            Throw 'Cannot dismount'
        }
        it 'Dismount fails'{
            {Move-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -dismount -ErrorAction Stop} | should throw
        }
    }
       
    Context -Name "Valid"{
        it "User used valid inputs"{
            {Move-FslToDisk -VHD $VHD -Path $Path -Destination $Destination } | should not throw
        }
        it "Dismount switch"{
            {Move-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -dismount } | should not throw
        }
        it "Assert Mocks"{
            Assert-MockCalled -CommandName Mount-FslDisk -Times 1
            Assert-MockCalled -CommandName Move-Item -Times 2
            Assert-MockCalled -CommandName Dismount-FslDisk -Times 1
        }
    }
}