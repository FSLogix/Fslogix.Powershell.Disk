$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

$Path = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\FsLTest.vhdx"

Describe $sut{
    BeforeAll{
        Mock -CommandName Get-Diskimage -MockWith {
            [PSCustomObject]@{
                Size = 1000
            }
        }
        Mock -CommandName Get-Item -MockWith {
            [PSCustomObject]@{
                Extension = ".vhdx"
                BaseName = "FslTest"
            }
        }
    }
    Context -name "Outputs"{
        it 'Test outputs'{
            $output = Get-diskinformation -path $Path
            $output.Name | should be "FslTest.vhdx"
            $output.BaseName | should be "FslTest"
            $output.Format | should be "vhdx"
        }
        Mock -CommandName Get-Diskimage -MockWith {
            Throw 'Image'
        }
        it 'Throws'{
            {Get-Diskinformation $Path -ErrorAction Stop} | should throw
        }
        it 'assert mock called'{
            Assert-MockCalled -CommandName Get-Diskimage -Times 1
        }
    }
    Context -name "Inputs"{
        it 'Accepts normal input'{
            {Get-DIskinformation -path $Path} | should not throw
        }
        it 'Accepts pipeline'{
            {$Path | Get-Diskinformation} | should not throw
        }
        it 'Positional'{
            {Get-Diskinformation $path} | should not throw
        }
    }
}