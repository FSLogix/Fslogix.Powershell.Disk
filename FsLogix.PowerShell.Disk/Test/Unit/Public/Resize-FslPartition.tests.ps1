$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$VHD = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\Kim_S-0-2-26-1944519217-1788772061-1800150966-14812.VHD'
Describe $sut {
    context -name 'should throw' {
        BeforeAll {
            mock -CommandName Get-FslVhd -MockWith {
                [PSCustomObject]@{
                    Path = 'C:\Users\danie\Documents\VHDModuleProject'
                }
            }
            mock -CommandName Get-Driveletter -MockWith {
                return 'D:\'
            }
            mock -CommandName Get-Disk -MockWith {
                [PSCustomObject]@{
                    Location = 'C:\Users\danie\Documents\VHDModuleProject'
                    Number = 2
                }
            }
            mock -CommandName Get-Partition -MockWith {
                [PSCustomObject]@{
                    Driveletter     = 'D:\'
                    PartitionNUmber = 2
                }
            }
            mock -CommandName Resize-Partition -MockWith {}
        }
        it 'invalid path' {
            {Resize-fslpartition -path 'C:\blah' -SizeInGb 2} | should throw
        }
        it 'Resize-Partition failed for x reason'{
            mock -CommandName Resize-Partition -MockWith {throw}
            {Resize-FslPartition -path $VHD -SizeInGb 2} | should throw
        }
    }
    Context -Name 'mock'{
        BeforeAll{
            mock -CommandName Resize-Partition -MockWith {}
        }
        it 'Invalid partition number throws'{
            {Resize-FslPartition -path $VHD -SizeInGb 2 -PartitionNumber 35} | should throw
        }
        it 'normal input, does not throw'{
            {Resize-FslPartition -path $VHD -SizeInGb 2} | should not throw
        }
    }
}