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
        mock -CommandName Test-path -MockWith {}
        Mock -CommandName Get-Aduser -MockWith {
            [PSCustomObject]@{
                SamAccountName = "Daniel"
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
            {Add-FslDisk -user "Daniel" -Destination "C:\test"} | should throw
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
            {Add-FslDisk -user "Daniel" -Destination "C:\test"} | should throw
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
            {Add-FslDisk -user "Daniel" -Destination "C:\test" -ErrorAction Stop} | should throw
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
            {Add-FslDisk -user "Daniel" -Destination "C:\test"} | should not throw
        }
        it 'Assert mocks called' {
            Assert-MockCalled "Get-AdUser" -Times 1
        }
    }
    Context -name "parameters"{
        mock -CommandName test-path -MockWith {
            $true
        }
        it 'Passthru'{
            $output = Add-FslDisk -user "Daniel" -Destination "C:\test" -Passthru
            $output.Name | should be "ODFC_Daniel.vhdx"
            $output.format | should be "vhdx"
        }
        it 'Type'{
            {Add-FslDisk -user "Daniel" -Destination "C:\test" -Type 0} | should not throw 
        }
        it 'Size'{
            {Add-FslDisk -user "Daniel" -Destination "C:\test" -SizeInMB 10000} | should not throw
        }
    }

}
