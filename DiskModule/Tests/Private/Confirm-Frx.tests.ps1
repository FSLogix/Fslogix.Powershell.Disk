$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut {
    BeforeAll{
        Mock -CommandName Push-location -MockWith {}
        Mock -CommandName Set-Location -MockWith {}
        Mock -CommandName Pop-Location -MockWith {}
        Mock -CommandName Test-path -MockWith {}
        Mock -CommandName Get-ItemProperty -MockWith {
            [PSCustomObject]@{
                Blah = 'noooooooooo'
            }
        } 
    }
    Context 'Install path does not exist'{
        it 'Invalid path'{
            {Confirm-Frx -path "C:\blah" -ErrorAction Stop} | should throw
        }
        it 'invalid install path'{
            {Confirm-Frx -ErrorAction Stop} | should throw
        }
        it 'Assert mock was called'{
            Assert-MockCalled -commandName Get-ItemProperty -Times 1
        }
        it 'Assert script stopped'{
            Assert-MockCalled -CommandName Push-Location -Times 0
        }
    }
    Context 'Install Valid'{
        Mock -CommandName Get-ItemProperty -MockWith {
            [PSCustomObject]@{
                InstallPath = 'C:\test'
            }
        }
        mock -CommandName Test-path -MockWith {$true}
        it 'Install path was valid'{
            {Confirm-Frx} | should not throw
        }
        it 'assert mock was called'{
            Assert-MockCalled -CommandName Pop-Location -Times 1
            Assert-MockCalled -CommandName Test-path -Times 1
        }
    }
    Context 'Cannot find Frx'{
        Mock -CommandName Get-ItemProperty -MockWith {
            [PSCustomObject]@{
                InstallPath = 'C:\test'
            }
        }
        mock -CommandName Test-path -MockWith {$false}
        it 'Install path was valid'{
            {Confirm-Frx -ErrorAction Stop} | should throw
        }
        it 'assert mock was called'{
            Assert-MockCalled -CommandName Pop-Location -Times 1
            Assert-MockCalled -CommandName Test-path -Times 1
        }
    }
    Context "Found Frx"{
        Mock -CommandName Get-ItemProperty -MockWith {
            [PSCustomObject]@{
                InstallPath = 'C:\test'
            }
        }
        mock -CommandName Test-path -MockWith {$true}
        it 'Install path was valid'{
            {Confirm-Frx -ErrorAction Stop} | should not throw
        }
        it 'Passthru'{
            $command = Confirm-frx -passthru
            $command | should be "C:\test\frx.exe"
        }
    }
}