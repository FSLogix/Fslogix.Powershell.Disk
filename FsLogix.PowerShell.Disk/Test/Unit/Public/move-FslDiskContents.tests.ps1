$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    #NEED TO ADD MORE TEST CASES
    context -name 'Outputs that should throw'{
        BeforeEach{
            mock -CommandName Get-FslDisk -MockWith {
                [PSCustomObject]@{
                    Path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx'
                }
            }
            mock -CommandName get-driveletter -MockWith {} -Verifiable
            mock -CommandName join-path -MockWith {} -Verifiable
        }
        it 'Invalid vhd path'{
            {move-fsldiskcontents -path "C:\blah" -Destination "C:\Users\Danie\Documents" -Overwrite} | should throw
        }
        it 'Invalid destination'{
            {move-fsldiskcontents -path "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx" -Destination "C:\blah" -Overwrite} | should throw
        }
        it 'Invalid file path within VHD'{
            {move-FslDiskContents -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx' -FilePath 'Blah' -Destination 'C:\Users\Danie\Documents' -Overwrite} | should throw
        }
        it 'VHD is empty'{
            mock -CommandName get-childitem -MockWith {$false}
            {move-FslDiskContents -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhdx' -Destination 'C:\Users\Danie\Documents' -Overwrite} | should throw
        }
        it 'No VHDs in path'{
            {move-FslDiskContents -path 'C:\Users\danie\Documents\VHDModuleProject\FsLogix.PowerShell.Disk\Test\Unit\Public' -Destination 'C:\Users\Danie\Documents' -Overwrite} | should throw
        }
    }
    context -Name 'Should not throw'{
        BeforeEach{
            mock -CommandName move-item -MockWith {$true}
            mock -CommandName get-childitem -MockWith {
                [PSCustomObject]@{
                    Name = 'hi'
                    fullname = 'C:\blah'
                }
            }
            mock -CommandName Get-FslDisk -MockWith {
                [PSCustomObject]@{
                    Path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx'
                }
            }
            mock -CommandName test-path -MockWith {$true}
            mock -CommandName get-driveletter -MockWith {}
            mock -CommandName join-path -MockWith {}
        }

        it 'test mock'{
            $path = Get-FslDisk -Path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx'
            $path.path | should be 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx'
        }
        
        it 'Valid inputs'{
            {move-FslDiskContents -vhdpath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx' -Destination 'C:\Users\Danie\Documents' -Overwrite} | should not throw
        }
        it 'overwrite'{
            {move-FslDiskContents -vhdpath 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest\testvhd2.vhdx' -Destination 'C:\Users\Danie\Documents'} | should not throw
        }
    }
}