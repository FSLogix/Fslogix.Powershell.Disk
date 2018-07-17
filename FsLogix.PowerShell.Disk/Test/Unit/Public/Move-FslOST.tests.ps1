$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    BeforeAll {
        Mock -CommandName Get-ADGroupMember -MockWith {
            [PSCustomObject]@{
                Name ='Daniel'
            }
        }
        Mock -CommandName Get-AdUser -MockWith{
            [PSCustomObject]@{
                Name = 'Daniel Kim'
                SamAccountName = 'Daniel'
                SID = 'S-0-2-26-1944519217-1788772061-1800150966-14811'
            }
        }
        mock -CommandName New-FslDisk -MockWith {$true} -Verifiable
        mock -CommandName copy-FslToDisk -MockWith {$true} -Verifiable
        mock -CommandName dismount-FslDisk -MockWith {$true} -Verifiable
        context -Name 'should throw'{
            it 'Invalid Ost path, must end with %username%'{
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\blah'}
            }
            it 'Invalid AppDirectoryPath'{
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\users\%username%' -AppData 'C:\blah'}
            }
        }

    }
}
