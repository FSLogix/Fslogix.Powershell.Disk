$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut{
    $Script:SamAccountName = "Daniel"
    $Script:SID = "0-2-26-1996"
    $Script:Path = "C:\Users\danie\Documents\VHDModuleProject\ODFCtest3"
    $Script:PipelineInput = [PSCustomObject]@{
        SamAccountName = $Script:SamAccountName
        SID = $Script:SID
        Path = $Script:Path
    }

    it 'Standard Input'{
        {Confirm-FslProfile -SamAccountName $Script:SamAccountName -SID $Script:SID -Path $Script:Path} | should not throw
    }
    it 'VHD switch'{
        {Confirm-FslProfile -SamAccountName $Script:SamAccountName -SID $Script:SID -Path $Script:Path -vhd} | should not throw
    }
    it 'pipeline by property'{
        {$Script:PipelineInput | Confirm-FslProfile } | should not throw
    }
    it 'Positional'{
        {Confirm-FslProfile $Script:Path $Script:SamAccountName $Script:SID} | should not throw
    }

}