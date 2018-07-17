$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"
dismount-fsldisk -dismountAll


Describe $sut {
    $path = 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\testvhd1.vhd'

    Context -name 'No VHDs attached should give warning' {
        it 'No VHDs should give warning' {
            dismount-fsldisk -dismountAll -WarningVariable Warn
            $warn.count | should be 1
        }
        mount-vhd $path -Passthru
    }
    Context -name 'Should not throw' {
        mock -CommandName dismount-vhd -MockWith {$true}
        it 'Accepts Pipeline' {
            {$path | dismount-FslDisk } | should be $true
        }
        it 'Calling dismount-fsldisk without path' {
            {dismount-FslDisk -dismountAll} | should not throw
        }
        it 'returns some verbose lines' {
            #-Verbose 4>&1 pipelines verbose 4 to 1
            $verboseLine = {dismount-FslDisk -fullname "C:\Users\danie\Documents\VHDModuleProject\ODFCTest\test.1.vhd" -Verbose 4>&1}
            $verboseLine.count | Should BeGreaterThan 0
        }
        it 'Valid path'{
            {$path | dismount-FslDisk } | should not throw
        }
    }
    Context -name 'should throw'{
        it 'User entered directory'{
            {dismount-FslDisk -path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest'} | should throw
        }
    }
}