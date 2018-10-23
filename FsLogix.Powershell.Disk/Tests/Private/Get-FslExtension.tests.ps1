$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut {

    $Script:Test1 = "Test.vhd"
    $Script:Test2 = "Test.vhd.vhdx"
    $Script:Test3 = "C:\Users\.daniel.test\"
    $Script:Test4 = "C:\users\daniel\test"
    $Script:Test5 = "C:\users\daniel\test.ps1"

    it 'Returns VHD'{
        $Extension = Get-Fslextension -Path $Script:Test1
        $Extension | Should be ".vhd"
    }
    it 'Returns VHDx'{
        $Extension = Get-Fslextension -Path $Script:Test2
        $Extension | Should be ".vhdx"
    }
    it 'Returns null'{
        $Extension = Get-Fslextension -Path $Script:Test3
        $Extension | Should be $null
    }
    it 'Returns null'{
        $Extension = Get-Fslextension -Path $Script:Test4
        $Extension | Should be $null
    }
    it 'Returns ps1'{
        $Extension = Get-Fslextension -Path $Script:Test5
        $Extension | Should be ".ps1"
    }

}