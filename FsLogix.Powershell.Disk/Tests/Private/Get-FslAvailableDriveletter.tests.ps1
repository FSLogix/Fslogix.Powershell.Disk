$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here -replace 'Tests', 'Functions'
. "$here\$sut"

Describe $sut{
    it 'Outputs'{
        {Get-Fslavailabledriveletter} | should not throw
    }
    it 'next'{
        {Get-Fslavailabledriveletter -next} | should not throw
    }
    it 'Random'{
        {Get-FslavailableDriveletter -random} | should not throw
    }
    mock -CommandName test-path -MockWith {$true}
    it 'None available'{
        {Get-Fslavailabledriveletter -ErrorAction Stop} | should throw
    }
}