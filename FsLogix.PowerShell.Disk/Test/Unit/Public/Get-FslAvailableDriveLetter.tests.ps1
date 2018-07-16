$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut{
    Context -Name 'Should not throw'{
        it 'User wants unmapped letters'{
            {get-fslavailabledriveletter} | should not throw
        }
        it 'User wants all letters'{
            {get-fslavailabledriveletter -all} | should not throw
        }
        it 'User wants next available out of all letters'{
            {get-fslavailabledriveletter -next} | should not throw
        }
        it 'user wants next available unmapped drive letter'{
            {get-fslavailabledriveletter -NextUnmapped } | should not throw
        }
        $Letter = get-fslavailabledriveletter -next
        it 'Next available letter'{
            $Letter = get-fslavailabledriveletter -next
            $Letter | should be 'D'
        }
    }
}