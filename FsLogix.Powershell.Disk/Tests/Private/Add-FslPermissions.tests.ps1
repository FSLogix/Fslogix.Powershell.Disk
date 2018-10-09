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
                Fullname = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Private\Add-FslPermissions.ps1'
                BaseName = "Add-FslPermissions.ps1"
            }
        }
        mock -CommandName Get-childitem -MockWith {
            [PSCustomObject]@{
                FullName = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Public'
                Basename = 'public'
            }
        }
        Mock -CommandName Get-Acl -MockWith {
            $Acl = Get-Acl 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Private\Add-FslPermissions.ps1'
        }
        Mock -CommandName New-Object -MockWith {
            system.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "Allow")
        }
        Mock -CommandName Set-Acl -MockWith {
            $Acl | set-acl
        }
    }
    Context -name "Mock AdUser"{
        it 'No errors'{
            {Add-FslPermissions -User "Daniel" -file $file} | should not throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName Get-Aduser -Times 1
        }
    }
    Context -name "input"{
        it 'Accepts Pipeline file'{
            {$File | Add-FslPermissions -user "Daniel"} | should not throw
        }
        it 'Accepts pipeline folder'{
            {$Folder | Add-FslPermissions -user "Daniel"} | should not throw
        }
        it 'Positional'{
            {Add-FslPermissions "Daniel" $file} | should not throw
        }
    }
}