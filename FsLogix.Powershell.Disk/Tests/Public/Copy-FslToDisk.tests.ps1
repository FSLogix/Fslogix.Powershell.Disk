$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut{

    $script:testDriveLetter = 'C:\'
    $Script:testSize = 500
    $Script:Partition = New-CimInstance -ClassName MSFT_Partition -Namespace /Microsoft/Windows/Storage -ClientOnly -Property @{DriveLetter=$script:testDriveLetter; Number = 1; FriendlyName = "Test"}
    $Script:MockedVolume = [PSCustomObject]@{
        SizeRemaining = 1000
    }
    #Microsoft.Management.Infrastructure.CimInstance#root\cimv2/MSFT_Disk
    #Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_Partition
    #Microsoft.Management.Infrastructure.CimInstance#/Microsoft/Windows/Storage/MSFT_Partition/MSFT_Disk

    $VHD = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3\FsLTest.vhdx"
    $Path = "C:\Users\danie\Documents\Scripts\Disk"
    $Destination = "Test"
    
    BeforeAll {
        Mock -CommandName Mount-FslDisk -MockWith {
            [PSCustomObject]@{
                Path = $script:testDriveLetter
                DiskNumber = 1
                PartitionNumber = 1
            }
        }
        Mock -CommandName Get-Partition -MockWith { 
           $Script:Partition
        }
        Mock -CommandName Get-Volume -MockWith {
            $Script:MockedVolume
        }
        Mock -CommandName Get-FslSize -MockWith {
            $Script:testSize
        }
        Mock -CommandName Invoke-expression -MockWith {}
        Mock -CommandName Dismount-FslDisk -MockWith {}
    }

    Context -name "Test-path"{
        mock -CommandName Test-path -MockWith {$false}
        it 'creates directory'{
            {Copy-FslToDisk -VHD $VHD -Path $Path -Destination $Destination} | should not throw
        }
        it 'Assert mock was called'{
            Assert-MockCalled -CommandName Test-path -Times 1
        }
        it 'Script did not stop'{
            Assert-MockCalled -CommandName Invoke-expression -Times 1
        }
        it 'Valid with switch parameters'{
            {Copy-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -Dismount} | should not throw
        }
        it 'Called switch mock'{
            Assert-MockCalled -CommandName Dismount-FslDisk -Times 1
        }
        it 'returns some verbose lines'{
            $verboseLine = Copy-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -Verbose 4>&1
            $verboseLine.count | Should Be 1
        }
    }

    Context -Name "Mount-FslDisk Fails"{
        Mock -CommandName Mount-FslDisk -MockWith{
            Throw "Failed Mount"
        }
        it 'Mount fails'{
            {Copy-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -dismount -ErrorAction Stop} | should throw
        }
        it 'assert mock was called'{
            Assert-MockCalled -CommandName Mount-FslDisk -Times 1
        }
        it 'Does not continue script' {
            Assert-MockCalled -CommandName Dismount-FslDisk -Times 0
            #Assert-MockCalled -CommandName Copy-Item -Times 0
        }
    }

    <#Context -name "Copy-Item fails"{
        Mock -CommandName Copy-Item -MockWith {
            Throw 'Cannot Copy'
        }
        it 'copy-item throws'{
            {Copy-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -ErrorAction Stop} | should throw
        }
        it "Script stops, dismount won't be called."{
            {Copy-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -ErrorAction Stop -Dismount} | should throw
        }
        It 'Dismounts' {
            Assert-MockCalled -CommandName Dismount-FslDisk -Times 2
        }  
    }#>
    COntext -name "Invoke-expression fails"{
        Mock -CommandName Invoke-expression -MockWith {
            Throw 'Invoke'
        }
        it "Script stops, dismount won't be called."{
            {Copy-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -ErrorAction Stop -Dismount} | should throw
        }
        it 'Assert mock was called'{
            Assert-MockCalled -CommandName Invoke-expression -Times 1
        }
        It 'Dismounts' {
            Assert-MockCalled -CommandName Dismount-FslDisk -Times 1
        }  
    }
    Context -name "Dismount fails"{
        Mock -CommandName Dismount-FslDisk -MockWith {
            Throw 'Cannot dismount'
        }
        it 'Dismount fails'{
            {Copy-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -dismount -ErrorAction Stop} | should throw
        }
        it 'Dismount can fail, should still have verbose output'{
            $verboseLine = Copy-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -Verbose 4>&1
            $verboseLine.count | Should Be 1
        }
    }
       
    Context -Name "Valid"{
        it "User used valid inputs"{
            {Copy-FslToDisk -VHD $VHD -Path $Path -Destination $Destination } | should not throw
        }
        it "Dismount switch"{
            {Copy-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -dismount } | should not throw
        }
        it "Assert Mocks"{
            Assert-MockCalled -CommandName Mount-FslDisk -Times 1
            #Assert-MockCalled -CommandName Copy-Item -Times 2
            Assert-MockCalled -CommandName Dismount-FslDisk -Times 1
        }
        it 'Verbose output'{
            $verboseLine = Copy-FslToDisk -VHD $VHD -Path $Path -Destination $Destination -Verbose 4>&1
            $verboseLine.count | Should Be 1
        }
    }
}