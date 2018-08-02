$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$fakeADUser1 = [PSCustomObject] @{
    Name           = 'Daniel Kim'
    SamAccountName = 'Daniel'
    SID            = 'S-0-2-26-1944519217-1788772061-1800150966-14811'
}
$fakeADUser2 = [PSCustomObject] @{
    Name           = 'Daniel Kim'
    SamAccountName = 'Kim'
    SID            = 'S-0-2-26-1944519217-1788772061-1800150966-14812'
}

Describe $sut {
    BeforeAll {
        Mock -CommandName Get-ADGroupMember -MockWith {
            return  @($fakeADUser1)
        } -ParameterFilter {
            "$identity" -eq 'Daniel'
        }

        Mock -CommandName Get-ADGroupMember -MockWith {
            return  @($fakeADUser2)
        } -ParameterFilter {
            "$identity" -eq 'Kim'
        }

        Mock -CommandName Get-ADGroupMember -MockWith{
            return @($fakeADUser1, $fakeADUser2)
        } -ParameterFilter{
            "$identity" -eq 'All'
        }

        mock -CommandName New-FslDisk -MockWith {$true} -Verifiable
        mock -CommandName copy-FslToDisk -MockWith {$true} -Verifiable
        mock -CommandName dismount-FslDisk -MockWith {$true} -Verifiable
        context -Name 'should throw' {
            it 'Invalid AppDirectoryPath' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\users\%username%' -AppData 'C:\blah'} | should throw
            }
            it 'Invalid DiskDestination' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users\Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811' -DiskDestination 'C:\blah'} | should throw
            }
            it 'Invalid AppData' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2'} | should throw
            }
            it 'invalid OST'{
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject'} | should throw
            }
            it 'App Data is not a folder' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\ost\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\ODFC\Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811.vhd' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject'} | should throw
            }
            it 'Could not get users in appdata folder' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\ost\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\Disk\Fslogix.Powershell.Disk\FsLogix.PowerShell.Disk\Test\Unit\Public\Move-FslOST.tests.ps1' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject'} | should throw
            }
            it 'No appdata in user profile'{
                mock -CommandName get-childitem -MockWith {$false} -ParameterFilter{
                    $path -eq 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users\Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811'
                }
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\ost\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject'} | should throw
            }
        }
        context -Name 'Should not throw' {
            BeforeEach{
                Mock -CommandName test-path -MockWith{$true}
            }
            it 'Valid Input 2 ad users' {
                {Move-FslOst -AdGroup 'all' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\ost\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject'} | should not throw
            }
            it 'Valid Input ad daniel' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\ost\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject'} | should not throw
            }
            it 'Valid Input ad kim' {
                {Move-FslOst -AdGroup 'Kim' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\ost\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject'} | should not throw
            }
            it 'Valid vhdformat Input' {
                {Move-FslOst -AdGroup 'Daniel' -vhdformat 'vhdx' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\ost\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject'} | should not throw
            }
            it 'Valid vhdformat Input' {
                {Move-FslOst -AdGroup 'Daniel' -vhdformat 'vhd' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\ost\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject'} | should not throw
            }
            it 'returns some verbose lines' {
                #-Verbose 4>&1 pipelines verbose 4 to 1
                $verboseLine = {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users\Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject' -Verbose 4>&1}
                $verboseLine.count | Should BeGreaterThan 0
            }
        }
        Context -name 'Test get-adgroupmember' {
            it 'Get-Adgroupmember should be 1 for Identity Daniel' {
                (Get-ADGroupMember -Identity 'Daniel' | Measure-Object).Count | should be 1
            }
            it 'Get-Adgroupmember should be 2 for Identity All' {
                (Get-ADGroupMember -Identity 'All' | Measure-Object).Count | should be 2
            }
            it 'Test name - Identity Daniel' {
                $output = Get-ADGroupMember -Identity 'Daniel'
                $output.name | should be 'Daniel Kim'
            }
            it 'Test Samaccount name - Identity Daniel' {
                $output = Get-ADGroupMember -Identity 'Daniel'
                $output.SamAccountName | should be 'Daniel'
            }
            it 'Test SID - Identity Kim' {
                $output = Get-ADGroupMember -Identity 'Kim'
                $output.SID | should be 'S-0-2-26-1944519217-1788772061-1800150966-14812'
            }
        }

    }
}
