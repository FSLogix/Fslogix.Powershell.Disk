$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

$script:file = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Public\Add-FslPermissions.ps1'
$script:Folder = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Public'
$Script:PermissionType = @("ReadData","Read")
$script:PipelineInput = [PSCustomObject]@{
    User = "Daniel"
    File = $script:file
    PermissionType = $Script:PermissionType
}


Describe $sut{
    
    BeforeAll{
        Mock -CommandName Get-Aduser -MockWith {
            [PSCustomObject]@{
                SamAccountName = "Everyone"
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
        mock -CommandName Set-Acl -MockWith {}
    }

    <#
        HOW TO MOCK ACL OBJECT??????????????
        ahhhhh
    #>
    Context -name "Mock AdUser"{
        $Error.Clear()
        it 'Does not throw'{
            {Add-FslPermissions -User "Daniel" -file $file} | should not throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName Get-Aduser -Times 1
        }
        it 'No errors were called'{
            $Error.Count | should be 0
        }
        it 'Assert script did not stop'{
            Assert-MockCalled -CommandName Set-Acl -Times 1
        }
        Mock -CommandName Get-Aduser -MockWith {
            Throw 'User'
        }
        it 'Throws'{
            {Add-FslPermissions -User "Daniel" -file $file -ErrorAction Stop} | should throw
        }
        it 'Assert mock called'{
            Assert-MockCalled -CommandName Get-Aduser -Times 1
        }
        it 'error was called'{
            $Error.count | should be 2
        }
    }
    Context -name "input"{
        it 'Accepts Pipeline file'{
            {$File | Add-FslPermissions -user "Daniel"} | should not throw
        }
        it 'Positional'{
            {Add-FslPermissions "Daniel" $file} | should not throw
        }
        it 'pipeline by property'{
            {$script:PipelineInput | Add-FslPermissions} | Should not throw
        }
        it 'Accepts PermissionType and Permission'{
            {Add-FslPermissions "Daniel" $file -PermissionType $Script:PermissionType -Permission "Allow"} | should not throw
        }
        it 'invalid folder path'{
            {Add-FslPermissions "Daniel" -Folder 'c:\blah'} | should throw
        }
        it 'invalid file path'{
            {Add-FslPermissions "Daniel" -file 'C:\blah'} | should throw
        }
        it 'input file into folder parameter should throw'{
            {Add-FslPermissions "Daniel" -Folder $script:Folder} | should throw
        }
        it 'valid folder does not throw'{
            mock -CommandName Get-Item -MockWith {
                [PSCustomObject]@{
                    Attributes = "Directory"
                    Fullname = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Public\Add-FslPermissions.ps1'
                    BaseName = "Add-FslPermissions.ps1"
                }
            }
            {Add-FslPermissions "Daniel" -Folder $script:Folder} | should not throw
        }
        <#it 'Inherit'{
            {Add-FslPermissions "Daniel" -Folder $script:Folder -inherit} | should not throw
        }#>
    }
    Context -name "File Input"{
        mock -CommandName Get-Item -MockWith {
            [PSCustomObject]@{
                Attributes = "Directory"
                Fullname = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Public\Add-FslPermissions.ps1'
                BaseName = "Add-FslPermissions.ps1"
            }
        }
        it 'Does not accept directory'{
            {$script:PipelineInput | Add-FslPermissions} | should throw
        }
        it 'assert mock was called'{
            Assert-MockCalled -CommandName Get-Item -Times 1
        }
        mock -CommandName Get-Item -MockWith {
            [PSCustomObject]@{
                Attributes = "Archive"
                Fullname = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Public\Add-FslPermissions.ps1'
                BaseName = "Add-FslPermissions.ps1"
            }
        }
        it 'File input should not throw'{
            {$script:PipelineInput | Add-FslPermissions} | should not throw
        }

    }
    Context -name "ACL"{
        Mock -CommandName Get-ACL -MockWith {
            Throw 'ACL'
        }
        it 'File Throws'{
            {$script:PipelineInput | Add-FslPermissions -ErrorAction Stop} | should throw
        }
        it 'Assert mock was called'{
            Assert-MockCalled -CommandName Get-Acl -Times 1
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName Set-acl -Times 0
        }
        mock -CommandName Get-Item -MockWith {
            [PSCustomObject]@{
                Attributes = "Directory"
                Fullname = 'C:\Users\danie\Documents\Scripts\Disk\Fslogix.Powershell.Disk\FsLogix.Powershell.Disk\Functions\Public\Add-FslPermissions.ps1'
                BaseName = "Add-FslPermissions.ps1"
            }
        }
        it 'Folder Throws'{
            {Add-FslPermissions "Daniel" -folder $script:Folder -ErrorAction Stop} | should throw
        }
        it 'Assert mock was called'{
            Assert-MockCalled -CommandName Get-Acl -Times 1
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName Set-acl -Times 0
        }
    }
}