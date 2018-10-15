$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'

$SamAccountName = "Daniel"
$SID = "0-2-26-1996"
$Destination = "test"
$Destination2 = "test\%Username%"
$AdUser = "Daniel Kim"

Describe $sut{

    BeforeAll{
        Mock -CommandName Get-AdUser -MockWith {
            [PSCustomObject]@{
                SamAccountName = "Daniel"
                SID = "0-2-26-1996"
            }
        }
        Mock -CommandName Remove-item -MockWith {}
        Mock -CommandName New-Item -MockWith {}
        #mock -CommandName Test-path -MockWith {}
    }
    Context -Name "Input"{
        it 'takes normal input'{
            {New-FslDirectory -SamAccountName $SamAccountName -SID $SID -Destination $Destination} | should not throw
        }
        it 'accepts pipeline input'{
            {$SamAccountName | New-FslDirectory -SID $SID -Destination $Destination } | should not throw
        }
        it 'accepts pipeline input2'{
            {$SID | New-FslDirectory -SamAccountName $SamAccountName -Destination $Destination } | should not throw
        }
        it 'Positional arguments'{
            {New-FslDirectory $SamAccountName $SID -destination $Destination} | should not throw
        }
        it '%username%'{
            {New-FslDirectory -SamAccountName $SamAccountName -SID $SID -Destination $Destination2} | should not throw
        }
        it 'AdUser'{
            {New-FslDirectory -aduser $AdUser -Destination $Destination} | should not throw
        }
        it 'pipeline'{
            {$AdUser | New-FslDirectory -Destination $Destination} | should not throw
        }
    }
    Context -name 'Mock AdUser'{
        Mock -CommandName Get-Aduser -MockWith {
            Throw 'User'
        }
        it 'throws'{
            {New-FslDirectory -user "Test" -Destination $Destination -ErrorAction Stop} | should throw
        }
        it 'assert mock called'{
            Assert-MockCalled -CommandName Get-Aduser -Times 1
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName New-Item -Times 0
        }
    }
    Context -name 'Test-path'{
        Mock -CommandName test-path -MockWith {$True}
        it 'Remove directory'{
            {New-FslDirectory -SamAccountName $SamAccountName -SID $SID -Destination $Destination} | should not throw
            Assert-MockCalled -CommandName Remove-item -Times 1
        }
    }
    Context -name 'Flip-Flop'{
        it "Normal"{
            $command = New-FslDirectory -SamAccountName $SamAccountName -SID $SID -Destination $Destination -Passthru
            $command | should be "test\Daniel_0-2-26-1996"
        }

        it "Flip-Flop"{
            $command = New-FslDirectory -SamAccountName $SamAccountName -SID $SID -Destination $Destination -Passthru -FlipFlop
            $command | should be "test\0-2-26-1996_Daniel"
        }
    }
    Context -name 'Passthru'{
        it 'no output'{
            $command = New-FslDirectory -SamAccountName $SamAccountName -SID $SID -Destination $Destination
            $command | should be $null
        }
        it 'passthru output'{
            $command = New-FslDirectory -SamAccountName $SamAccountName -SID $SID -Destination $Destination -Passthru
            $command | should be "test\Daniel_0-2-26-1996"
        }
        it '%username%'{
            $command = New-FslDirectory -SamAccountName $SamAccountName -SID $SID -Destination $Destination2 -Passthru
            $command | should be "test\Daniel_0-2-26-1996"
        }
    }
    Context -name 'New-Item'{
        Mock -CommandName New-Item -MockWith {
            Throw 'New'
        }
        it 'Throws'{
            {New-FslDirectory -SamAccountName $SamAccountName -SID $SID -Destination $Destination -ErrorAction Stop} | should throw
        }
        it 'assert mock called'{
            Assert-MockCalled -CommandName New-Item -Times 1
        }

    }
}