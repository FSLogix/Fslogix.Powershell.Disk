$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut {
    BeforeAll {
        Mock -CommandName Push-location -MockWith {}
        Mock -CommandName Set-Location -MockWith {}
        Mock -CommandName Add-FslPermissions -MockWith {}
        Mock -CommandName Invoke-Expression -MockWith {}
        Mock -CommandName Pop-Location -MockWith {}
        Mock -CommandName Set-FslDriveLetter -MockWith {}
        Mock -CommandName Add-FslDriveLetter -MockWith {}
        mock -CommandName Test-path -MockWith {
            $true
        }
        Mock -CommandName Get-Aduser -MockWith {
            [PSCustomObject]@{
                SamAccountName = "Daniel"
                SID            = "S-0-2-26-1996"
            }
        }
        Mock -CommandName Get-ItemProperty -MockWith {
            [PSCustomObject]@{
                InstallPath = "C:\Users\danie\Documents\VHDModuleProject"
            }
        }
        Mock -CommandName Get-FslDisk -MockWith {
            [PSCustomObject]@{
                Name   = "ODFC_Daniel.vhdx"
                Format = "vhdx"
            }
        }
    }
    Context -name "No FsLogix Apps installed" {
        Mock -CommandName Get-ItemProperty -MockWith {
            Throw "No apps!"
        }
        it "FsLogix Applications not found" {
            {New-FslDisk -user "Daniel" -Destination "C:\test"} | should throw
        }
        it 'assert mock was called' {
            Assert-MockCalled -CommandName Get-itemproperty -Times 1
        }
        it 'assert script stopped' {
            Assert-MockCalled -commandname Push-location -Times 0
        }
    }
    Context -Name "No Frx.exe found" {
        Mock -CommandName Test-path -MockWith {
            $false
        }
        it "Frx.exe not found" {
            {New-FslDisk -user "Daniel" -Destination "C:\test"} | should throw
        }
        it 'assert script stopped' {
            Assert-MockCalled -CommandName Get-Aduser -times 0
        }
    }
    Context -Name "Get-Aduser" {
        mock -CommandName test-path -MockWith {
            $true
        }
        mock -CommandName Get-AdUser -MockWith {
            Throw "invalid User"
        }
        it 'Invalid User throws' {
            {New-FslDisk -user "Daniel" -Destination "C:\test" -ErrorAction Stop} | should throw
        }
        it 'Assert script stopped' {
            Assert-MockCalled -CommandName Invoke-Expression -Times 0
        }
        Mock -CommandName Get-Aduser -MockWith {
            [PSCustomObject]@{
                SamAccountName = "Daniel"
            }
        }
        it 'No errors with valid user' {
            {New-FslDisk -user "Daniel" -Destination "C:\test"} | should not throw
        }
        it 'Assert mocks called' {
            Assert-MockCalled "Get-AdUser" -Times 1
        }
    }
    Context -name "Add-FslPermissions fails" {
        it 'Throws' {
            Mock -CommandName Add-FslPermissions -MockWith {
                Throw "Permissions"
            }
            {New-Fsldisk -user "Daniel" -Destination "C:\test" -Passthru -ErrorAction Stop} | should throw
        }
        it 'Assert mock called' {
            Assert-MockCalled -CommandName Add-FslPermissions -Times 1
            Assert-MockCalled -CommandName Pop-Location -Times 1
        }
        it 'assert script stopped' {
            Assert-MockCalled -CommandName Get-Fsldisk -Times 0
        }
    }
    Context -name "parameters" {
        mock -CommandName test-path -MockWith {
            $true
        }
        it 'Passthru' {
            $output = New-FslDisk -user "Daniel" -Destination "C:\test" -Passthru
            $output.Name | should be "ODFC_Daniel.vhdx"
            $output.format | should be "vhdx"
        }
        it 'Type' {
            {New-FslDisk -user "Daniel" -Destination "C:\test" -Type 0} | should not throw 
        }
        it 'invalid type should throw' {
            {New-FslDisk -user "Daniel" -Destination "C:\test" -Type 2} | should  throw
        }
        it 'Size' {
            {New-FslDisk -user "Daniel" -Destination "C:\test" -SizeInMB 10000} | should not throw
        }
        it 'Label' {
            {New-FslDisk -user "Daniel" -Destination "C:\test" -Label "Test"} | should not throw
        }
        it 'VHD' {
            {New-FslDisk -user "Daniel" -Destination "C:\test" -vhd } | should not throw
        }
    }
    Context -name "DriveLetter"{
        it 'AssignDriveletter switch'{
            {New-FslDisk -user "Daniel" -Destination "C:\test" -AssignDriveLetter } | should not throw
        }
        it 'assert mock called'{
            Assert-MockCalled -CommandName Add-FslDriveLetter -Times 1
        }
        it 'assigndriveletter with letter parameter'{
            {New-FslDisk -user "Daniel" -Destination "C:\test" -AssignDriveLetter -Letter 't'} | should not throw
        }
        it 'assert mock called'{
            Assert-MockCalled -CommandName set-FslDriveLetter -Times 1
        }
        it 'Set-FslDriveletter throws'{
            Mock -CommandName Set-FslDriveLetter -MockWith {
                Throw "set"
            }
            {New-FslDisk -user "Daniel" -Destination "C:\test" -AssignDriveLetter -Letter 't' -Passthru -ErrorAction Stop} | should throw
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName Get-Fsldisk -times 0
        }
        it 'Add-FslDriveLetter throws'{
            Mock -CommandName Add-FslDriveLetter -MockWith {
                Throw "Add"
            }
            {New-FslDisk -user "Daniel" -Destination "C:\test" -AssignDriveLetter -Passthru -ErrorAction Stop} | should throw
        }
        it 'assert script stopped'{
            Assert-MockCalled -CommandName Get-Fsldisk -times 0
        }
    }
}
