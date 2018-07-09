$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

describe $sut{
   
    context -name "Output should throw"{
        it 'Invalid VHD path'{
            {move-FslToDisk -path "C:\blah" -FilePath "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit\Public"} | should throw
        }

        it 'Invalid File Path'{
            {move-FslToDisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx" -filepath "C:\blah"} |  should throw
        }

        it 'No VHDs found in path'{
            {move-FslToDisk -path "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit\Public" -FilePath "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit\Public"} | out-null | should throw
        }
        it 'Optional destination parameter is invalid'{
            {move-FslToDisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx" -filepath "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit\Private" -Destination 'blahasdf'} | should throw
        }
    }
    Context -name 'Should not throw'{
        BeforeEach{
            mock -CommandName Move-Item -MockWith {$true}
        }
        it 'Valid input'{
            {move-FslToDisk -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx" -filepath "C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit\Private"} | should not throw
        }
    }
}