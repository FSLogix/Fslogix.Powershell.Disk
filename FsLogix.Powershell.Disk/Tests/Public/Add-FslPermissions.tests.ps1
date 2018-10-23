$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

$file = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Public\Add-FslPermissions.ps1'
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
                Fullname = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Public\Add-FslPermissions.ps1'
                BaseName = "Add-FslPermissions.ps1"
            }
        }
        mock -CommandName Get-childitem -MockWith {
            [PSCustomObject]@{
                FullName = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Public'
                Basename = 'public'
            }
        }
    }
    <#
        HOW TO MOCK ACL OBJECT??????????????
        ahhhhh
    #>
    Context -name "Mock AdUser"{
        $Error.Clear()
        it 'No errors'{
            {Add-FslPermissions -User "Daniel" -file $file} | should not throw
            $Error.Count | should be 0
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