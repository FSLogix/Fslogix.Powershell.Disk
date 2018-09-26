$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    Context -Name 'General tests' {
        BeforeEach {
            mock -CommandName remove-item -MockWith {} -Verifiable
            mock -CommandName get-childitem -MockWith {
                [PSCustomObject]@{
                    FullName = 'C:\programdata\FsLogix\FslGuid\hi.txt'
                    LinkType = 'junction'
                }
            }
        }
    
        it 'should throw' {
            {Clear-FslGuid -GuidPath 'C:\blah'} | should throw
        }
        it 'should not throw' {
            {Clear-FslGuid} | should not throw
        }
        it 'If a guid folder was never generated'{
            mock -CommandName Test-Path -MockWith {
                $false
            }
            {Clear-FslGuid} | should throw
        }
        it 'This will need to be tested. If guid generated is not a junction type'{
            mock -CommandName get-childitem -MockWith {
                [PSCustomObject]@{
                    FullName = 'C:\programdata\FsLogix\FslGuid\hi.txt'
                    LinkType = 'idk'
                }
            }
            {Clear-FslGuid} | should throw
        }
    }
    context -name 'Test folder' {
        it 'Should be empty' {
            Clear-FslGuid -WarningVariable Warn
            $out = get-childitem 'C:\programdata\FsLogix\FslGuid'
            $out | should be $Null
            $warn.count | should be 1
        }
    }
    
}