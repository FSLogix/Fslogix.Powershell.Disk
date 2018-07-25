$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$ValidFolder = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest3'
$ValidSID = 'S-0-2-26-1944519217-1788772061-1800150966-14812'
$ValidName = 'Kim'

Describe $sut {
    Context -Name 'Should throw Warning Messages' {
        it 'Invalid folder' {
            {Test-FslProfile -VhdFolder 'C:\blah' -strSid $ValidSID -strUserName $ValidName -ErrorAction Stop} | should throw
        }
        it 'Path is not a directory'{
            {Test-FslProfile -VhdFolder 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Private\ConvertTo-VHD.ps1' -strSid $ValidSID -strUserName $ValidName -WarningAction Stop} | should throw
        }
        it 'Incorrect SID'{
            {Test-FslProfile -VhdFolder $ValidFolder -strSid 'lol' -strUserName 'Kim' -WarningAction Stop} | should throw
        }
        it 'Invalid Directory name'{
            {Test-FslProfile -VhdFolder $ValidFolder -strSid $ValidSID -strUserName 'noooo' -WarningAction Stop} | should throw
        }
        it 'VHD is corrupted'{
            Mock -CommandName Test-VHD -MockWith {return $false}
            {Test-FslProfile -VhdFolder $ValidFolder -strSid $ValidSID -strUserName $ValidName -WarningAction Stop} | should throw
        }
        it 'could not find profile.vhd'{
            mock -CommandName Test-Path -MockWith {
                $false
            } -ParameterFilter{$path -eq 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest3\Kim_S-0-2-26-1944519217-1788772061-1800150966-14812\profile.vhd'}
            {Test-FslProfile -VhdFolder $ValidFolder -strSid $ValidSID -strUserName $ValidName -WarningAction Stop} | should throw
        }
        it 'Output should be false'{
            $output = Test-FslProfile -VhdFolder $ValidFolder -strSid $ValidSID -strUserName $ValidName
            $output | should be $false
        }
       
    }
    Context -Name "should not throw"{
        it 'Valid inputs'{
            {Test-FslProfile -VhdFolder $ValidFolder -strSid $ValidSID -strUserName $ValidName} | should not throw
        }
        it 'should be true'{
            $output = Test-FslProfile -VhdFolder $ValidFolder -strSid $ValidSID -strUserName $ValidName
            $output | should be $true
        }
        it 'VHD'{
            {Test-FslProfile -VhdFolder $ValidFolder -strSid $ValidSID -strUserName $ValidName -vhd} | should not throw
        }
        it 'VHDx'{
            {Test-FslProfile -VhdFolder $ValidFolder -strSid $ValidSID -strUserName $ValidName -vhdx} | should not throw
        }
    }
}
