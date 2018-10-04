$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

$Path = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\yeahright.vhd"
$Path2 = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\Test1 - Copy - Copy.vhd"
$folder = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3"
Describe $sut {
    Context -Name "Should Throw"{
        it 'Incorrect path given'{
            {Get-FslDisk -path 'C:\blah'} | should throw
        }
        it 'Incorrect Folder path given'{
            {Get-Fsldisk -folder 'C:\blah'} | should throw
        }
    }
    BeforeAll{
        Mock -CommandName Get-DiskImage -MockWith {
            [PSCustomObject]@{
                ImagePath           = $Path
                Attached            = $true
                Size                = 10gb
                FileSize            = 8gb
            }
        }
        Mock -CommandName Get-Item -MockWith {
            [PSCustomObject]@{
                Extension = ".VHD"
                BaseName  = 'yeahright'
            }
        }
        mock -CommandName Get-ChildItem -MockWith {
            [PSCustomObject]@{
                FullName = $Path
            }
            [PSCustomObject]@{
                FullName = $Path2
            }
        }
    }
    Context -name 'Test Path'{
        it 'Standard path given'{
            {Get-FslDisk -path $path} | Should not throw
        }
        it 'accepts pipeline input'{
            {$Path | get-fsldisk } | should not throw
        }
        it 'ImagePath matches path'{
            $Command = Get-FslDisk -path $Path
            $Command.ImagePath | should be $path
        }
        it 'Attached should be true'{
            $Command = Get-FslDisk -path $path
            $Command.Attached | should be $true
        }
        it 'Format should be VHD'{
            $Command = Get-FslDisk -path $Path
            $Command.Format | should be "VHD"
        }
        it "Name should be 'yeahright.vhd'"{
            $Command = Get-FslDisk -path $path
            $Command.Name | should be "Yeahright.vhd"
        }
        it "basename should be yeahright"{
            $Command = Get-Fsldisk -path $path
            $Command.basename | should be "yeahright"
        }
        it "Attached should be false for different values"{
            Mock -CommandName Get-DiskImage -MockWith {
                [PSCustomObject]@{
                    ImagePath           = $Path
                    Attached            = $false
                    Size                = 5gb
                    FileSize            = 2gb
                }
            }
            $Command = Get-Fsldisk -path $Path
            $Command.Attached | should be $false
        }
    }
    Context -name 'Test Folder'{
        it 'Standard command should not throw'{
            {Get-Fsldisk -folder $folder} | should not throw
        }
        it 'Should have two outputs'{
            $Command = Get-FslDisk -folder $folder
            $Command.Count | should be 2
        }
    }
}