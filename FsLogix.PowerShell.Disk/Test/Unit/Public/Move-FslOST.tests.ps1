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
              return  @($fakeADUser1, $fakeADUser2)

        }

        mock -CommandName New-FslDisk -MockWith {$true} -Verifiable
        mock -CommandName copy-FslToDisk -MockWith {$true} -Verifiable
        mock -CommandName dismount-FslDisk -MockWith {$true} -Verifiable
        context -Name 'should throw' {
            it 'Invalid Ost path, must end with %username%' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\blah'} | should throw
            }
            it 'Invalid AppDirectoryPath' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\users\%username%' -AppData 'C:\blah'} | should throw
            }
            it 'Invalid DiskDestination' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users\Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811' -DiskDestination 'C:\blah'} | should throw
            }
            it 'Invalid AppData and OST' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2'} | should throw
            }
            it 'App Data is not a folder'{
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\ost\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\ODFC\Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811.vhd' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject'} | should throw
            }
        }
        context -Name 'Should not throw' {
            it 'Valid Input' {
                {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\ost\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject'} | should not throw
            }
            it 'Valid vhdformat Input' {
                {Move-FslOst -AdGroup 'Daniel' -vhdformat 'vhdx' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\ost\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject'} | should not throw
            }
            it 'Get-Adgroupmember should be 2' {
                (Get-ADGroupMember -Identity 'Daniel' | Measure-Object).Count | should be 2
            }
    
            it 'returns some verbose lines' {
                #-Verbose 4>&1 pipelines verbose 4 to 1
                $verboseLine = {Move-FslOst -AdGroup 'Daniel' -SizeInGB '2' -Ost 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users\%username%' -AppData 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users\Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811' -DiskDestination 'C:\Users\danie\Documents\VHDModuleProject' -Verbose 4>&1}
                $verboseLine.count | Should BeGreaterThan 0
            }
            <#
                How to test these?

                File            Function    Line Command
                ----            --------    ---- -------
                Move-FslOst.ps1 Move-FslOst  129 $userData = get-aduser $_
                Move-FslOst.ps1 Move-FslOst  131 [System.String]$FSLFullUser = $userData.Name
                Move-FslOst.ps1 Move-FslOst  132 [System.String]$FSLUser = $userData.SamAccountName
                Move-FslOst.ps1 Move-FslOst  133 [System.String]$strSid = $userData.SID
            #>
        }

    }
}
