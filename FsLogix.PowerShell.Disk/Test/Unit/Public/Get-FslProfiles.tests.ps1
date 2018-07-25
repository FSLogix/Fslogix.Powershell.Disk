$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

$Dir = 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\Users'
$user = 'Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811'

Describe $sut {
    context -Name 'Should throw'{
        it 'Invalid path'{
            {get-fslprofiles -UserDirectory 'C:\blah'} | should throw
        }
        it 'No directories in path gives 2 warning'{
            get-fslprofiles -UserDirectory 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2' -WarningVariable warn
            $warn.count | should be 2
        }
        it 'Unable to find any users gives 1 warning'{
            get-fslprofiles -UserDirectory 'C:\Users\danie\Documents\VHDModuleProject\ProfileMigration\OST' -WarningVariable warn
            $warn.count | should be 1
        }
    }
    Context -name 'Should not throw'{
        it 'valid directory'{
            {Get-fslprofiles -UserDirectory $Dir} | should not throw
        }
        it 'confirm outputs'{
            $output = get-fslprofiles -UserDirectory $Dir
            $output.name[0] | should be $user
        }
        it 'confirm output count'{
            $output = get-fslprofiles -UserDirectory $Dir
            $output.count | should be 2
        }
    }
}