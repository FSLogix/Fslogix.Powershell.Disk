$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'

Describe $sut{
    BeforeAll{
        Mock -CommandName Confirm-Frx -MockWith {
            "C:\Users\danie\Documents\Scripts\DavidYoung\Migrate-Ost"
        }
        Mock -CommandName Set-location -MockWith {}
        Mock -CommandName Get-ADGroupMember -MockWith {
            [PSCustomObject]@{
                Name = "Daniel Kim"
                SID = "0-2-26-1996"
                SamAccountName = "Daniel"
            }
        }
        Mock -CommandName Remove-item -MockWith {}
        Mock -CommandName Invoke-Expression -MockWith {}
        mock -CommandName Add-FslPermissions -MockWith {}
        Mock -CommandName Mount-FslDisk -MockWith {
            [PSCustomObject]@{
                Mount = "test"
            }
        }
        Mock -CommandName Copy-item -MockWith {}
        Mock -CommandName Dismount-fsldisk -MockWith {}
        Mock -CommandName Rename-item -MockWith {}
        Mock -CommandName Remove-ADGroupMember -MockWith {}
    }
    Context -name "test"{
        . "$here\$sut"
    }
}