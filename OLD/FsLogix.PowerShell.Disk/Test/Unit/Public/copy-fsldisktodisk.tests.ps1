$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    BeforeAll {
        mock -CommandName Copy-Item -MockWith {}
        mock -CommandName dismount-FslDisk -MockWith {} -Verifiable
        mock -CommandName Get-Driveletter -MockWith {
            'C:\'
        }
    }
    Context -name 'Should throw' {
        $VHD1 = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
        $VHD2 = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd2.vhdx'
        it 'First VHD is invalid'{
            {Copy-FslDiskToDisk -path 'C:\blah' -destination $VHD2} | should throw
        }
        it 'Second VHD is invalid'{
            {Copy-FslDiskToDisk -path $VHD1 -destination "C:\blah"} | should throw
        }
        it 'First File Path is invalid'{
            Mock -CommandName Get-DriveLetter -MockWith {
                'C:\'
            }
            {Copy-FslDiskToDisk -path $VHD1 -file 'Blah' -Destination $VHD2} | should throw
        }
        it 'Second file path is invalid'{
            Mock -CommandName Get-Driveletter -MockWith {
                'C:\'
            }
            {Copy-FslDiskToDisk -path $VHD1 -file 'temp' -destination $VHD2 -file2 'Blah'} | should throw
        }
        it 'First VHD is empty should give warning'{
            Mock -CommandName Get-DriveLetter -MockWith {
                'C:\'
            }
            mock -CommandName Get-Childitem -MockWith {
                $null
            }
            Copy-FslDiskToDisk -Path $VHD1 -Destination $VHD2 -WarningVariable Warn
            $Warn.count | should be 1
        }
    }
    Context -Name "Should not throw"{
        $VHD1 = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'
        $VHD2 = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd2.vhdx'
        $File1 = 'Temp'
        $File2 = 'Users'
        BeforeAll{
            Mock -CommandName Get-Driveletter -MockWith {
                'C:\'
            }
            mock -CommandName Get-Childitem -MockWith{
                [PSCustomObject]@{
                    FullName = 'Test'
                }
            }
        }
        it 'VHD1 to VHD2'{
            {Copy-FslDiskToDisk -path $VHD1 -destination $VHD2} | should not throw
        }
        it 'VHD1 with folder to vhd2'{
            {Copy-FslDiskToDisk -path $VHD1 -file $file1 -destination $VHD2} | should not throw
        }
        it 'VHD1 to vhd2 folder'{
            {Copy-FslDiskToDisk -path $VHD1 -destination $VHD2 -file2 $file2} | should not throw
        }
        it 'VHD1 folder to VHD2 folder'{
            {Copy-FslDiskToDisk -path $VHD1 -file $file -destination $VHD2 -file2 $file2} | should not throw
        }
        it 'Overwrite Switch'{
            {Copy-FslDiskToDisk -path $VHD1 -destination $VHD2 -Overwrite} | should not throw
        }
    }
}
