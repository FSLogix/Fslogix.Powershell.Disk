$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$VHD = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'

Describe $sut{
    Mock -CommandName Remove-item -MockWith {$true}
    Mock -CommandName get-fslvhd -MockWith {
        return get-vhd $VHD
    }
    Mock -CommandName Export-csv -MockWith {$true}
    Context -Name "Should throw"{
        it 'Incorrect VHD path'{
            $command = {Get-FslAttachedDisk -path 'C:\blah'}
            $command | should throw
        }
        it 'Incorrect Csv path'{
            $command = {Get-FslAttachedDisk -csvfile 'C:\blah'}
            $command | should throw
        }
    }
    Context -name 'Should not throw'{
        it 'Calling the function by itself'{
            {Get-FslAttachedDisk} | should not throw
        }
        it 'Valid inputs'{
            {Get-FslAttachedDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -csvfile 'C:\Users\danie\Documents\VHDModuleProject\test.csv'} | should not throw
        }
        it 'outputs'{
            {Get-FslAttachedDisk -path $VHD} | should not throw
        }
        it 'disk info csv'{
            {Get-FslAttachedDisk -Csvfile 'C:\Users\danie\Documents\VHDModuleProject\test.csv'} | should not throw
        }
        it 'test output1'{
            $output = Get-FslAttachedDisk -path $VHD
            $output.name | should be $(Split-Path -path $VHD -leaf)
            $output.location | should be $vhd
        }
        it 'test output 2'{
            $output = Get-FslAttachedDisk -path $VHD
            $output.format | should be 'VHD'
            $output.Type | should be 'Dynamic'
        }
        it 'test output 3'{
            mock -CommandName get-fslvhd -MockWith {
                [PSCustomObject]@{
                    ComputerName  = $Env:COMPUTERNAME
                    Path          = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\NoDl.vhdx'
                    location      = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\NoDl.vhdx'
                    vhdFormat     = 'VHDx'
                    vhdType       = 'Fixed'
                    Size          = 1gb
                    Filesize      = .5gb
                 }
            }-Verifiable
            $output = Get-FslAttachedDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\NoDl.vhdx'
            $output.location | should be 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\NoDl.vhdx'
            $output.Format | should be 'VHDx'
        }
        it 'Asserts all verifiable mocks' {
            Assert-VerifiableMock
        }
    }
}