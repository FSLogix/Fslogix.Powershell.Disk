$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

$file = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Private\Add-FslPermissions.ps1'
$Folder = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Public'

Describe $sut{
    
    BeforeAll{
        Mock -CommandName Get-Aduser -MockWith {
            [PSCustomObject]@{
                SamAccountName = "Daniel"
            }
        }
        mock -CommandName Get-Item -MockWith {
            [PSCustomObject]@{
                Attributes = "Archive"
                Fullname = ""
                BaseName = ""
            }
        }
        mock -CommandName Get-childitem -MockWith {
            [PSCustomObject]@{
                FullName = ""
                Basename = ""
            }
        }
        Mock -CommandName Get-Acl -MockWith {}
        Mock -CommandName New-Object -MockWith {}
        Mock -CommandName Set-Acl -MockWith {}
    }
    Context -name "Mock AdUser"{
        it 'No errors'{
            {Add-FslPermissions -User "Daniel"} | should not throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName Get-Aduser -Times 1
        }
    }
}