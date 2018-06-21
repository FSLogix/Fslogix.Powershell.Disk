$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {

    Context -name 'Outputs should throw'{
        it 'Path is invalid'{
            $invalid_path = {move-FslDisk -path "C:\users\blah" -Destination 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest'} | Out-Null
            $invalid_path | should throw
        }
        it 'Destination is invalid'{
            $invalid_path = {move-fsldisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -Destination 'blah'} | Out-Null
            $invalid_path | should throw
        }
        it 'Unable to find VHDs in path'{
            $invalid_path = {move-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test' -Destination 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test'} | Out-Null
            $invalid_path | should throw
        }
        it 'VHD is attached and in use'{
            mount-vhd -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd'
            $invalid_path = {move-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd' -Destination 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2'} | Out-Null
            $invalid_path | should throw
            dismount-vhd -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd'
        }
    }
    Context -name 'Outputs should not throw'{
        it 'Correct path to correct Destination'{
            {move-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest' -Destination 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2'} | should not throw
        }

        it 'Reverse migration'{
            {move-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2' -Destination 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest'} | should not throw
        }
    }
}