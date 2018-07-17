$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    BeforeAll {
        Mock -CommandName Get-ADGroupMember -MockWith {
            Mock -CommandName Get-AdUser -MockWith {
                [PSCustomObject]@{
                    Name           = 'Daniel Kim'
                    SamAccountName = 'Daniel'
                    SID            = 'S-0-2-26-1944519217-1788772061-1800150966-14811'
                }
                [PSCustomObject]@{
                    Name           = 'Daniel Kim'
                    SamAccountName = 'Kim'
                    SID            = 'S-0-2-26-1944519217-1788772061-1800150966-14812'
                }
            }
        }

        mock -CommandName New-FslDisk -MockWith {$true} -Verifiable
        mock -CommandName copy-FslToDisk -MockWith {$true} -Verifiable
        mock -CommandName dismount-FslDisk -MockWith {$true} -Verifiable
        context -Name 'should throw' {
            it 'Invalid Ost path, must end with %username%' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\blah'}
            }
            it 'Invalid AppDirectoryPath' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\users\%username%' -AppData 'C:\blah'}
            }
        }
        context -Name 'Should not throw' {
            it 'Valid Input' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users\Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject'} | should not throw
            }
            it 'Get-Adgroupmember should be 2' {
                (Get-AdUser -Filter 'Daniel' | Measure-Object).Count | should be 2
            }
        }

    }
}
