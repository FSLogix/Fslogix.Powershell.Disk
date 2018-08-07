$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$funcType = Split-Path $here -Leaf
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$here = $here | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
. "$here\$funcType\$sut"

Describe $sut {
    it 'should not throw'{
        {Get-fslDriveType 0} | should not throw
    }
    it 'should be fixed'{
        $cmd = get-fsldrivetype 0
        $cmd | Should be 'Network'
    }
    Context -name 'Cannot find Volume'{
        it 'Will need to bug fix if this ever happens'{
            Mock -CommandName Get-Partition -MockWith{
                [PSCustomObject]@{
                    Type = 'Basic'
                    AccessPaths = 'C:\ProgramData\FsLogix\FslGuid\test'
                    Guid = 'Test'
                }
            }
            mock -CommandName Get-WmiObject -mockwith{
                [PSCustomObject]@{
                    DeviceId = 'test2'
                    DriveType = 0
                }
            }
            Get-FslDriveType 0 -WarningVariable Warn
            $Warn.count | should be 1
        }
    }
    Context -Name 'Returns Guid'{
        Mock -CommandName Get-Partition -MockWith{
            [PSCustomObject]@{
                Type = 'Basic'
                AccessPaths = 'C:\ProgramData\FsLogix\FslGuid\test'
                Guid = '{Test}'
            }
        }
        mock -CommandName Get-WmiObject -mockwith{
            [PSCustomObject]@{
                DeviceId = '\\?\Volume{Test}\'
                DriveType = 0
            }
        }
        it 'should not throw'{
            {Get-fslDriveType 0} | should not throw
        }
    }
    Context -Name 'Returns DriveLetter'{
        Mock -CommandName Get-Partition -MockWith{
            [PSCustomObject]@{
                Type = 'Basic'
                AccessPaths = 'H:\'
            }
        }
        mock -CommandName Get-WmiObject -mockwith{
            [PSCustomObject]@{
                Driveletter = 'H:'
                DriveType = 1
            }
        }
        it 'should not throw'{
            {Get-fslDriveType 0} | should not throw
        }
    }
    Context -Name 'Returns \\?\Volume{*}\'{
        Mock -CommandName Get-Partition -MockWith{
            [PSCustomObject]@{
                Type = 'Basic'
                AccessPaths = '\\?\Volume{asdfsdf}\'
            }
        }
        mock -CommandName Get-WmiObject -mockwith{
            [PSCustomObject]@{
                DeviceId  = '\\?\Volume{asdfsdf}\'
                DriveType = 2
            }
        }
        it 'should not throw'{
            {Get-fslDriveType 0} | should not throw
        }
    }
    Context -name 'Returns different types'{
        Mock -CommandName Get-Partition -MockWith{
            [PSCustomObject]@{
                Type = 'Basic'
                AccessPaths = '\\?\Volume{asdfsdf}\'
            }
        }
        it 'unknown'{
            mock -CommandName Get-WmiObject -mockwith{
                [PSCustomObject]@{
                    DeviceId  = '\\?\Volume{asdfsdf}\'
                    DriveType = 0
                }
            }
            $Cmd = Get-FslDriveType 0
            $Cmd | should be 'unknown'
        }
        it 'Removeable'{
            mock -CommandName Get-WmiObject -mockwith{
                [PSCustomObject]@{
                    DeviceId  = '\\?\Volume{asdfsdf}\'
                    DriveType = 1
                }
            }
            $Cmd = Get-FslDriveType 0
            $Cmd | should be 'Removeable'
        }
        it 'Fixed'{
            mock -CommandName Get-WmiObject -mockwith{
                [PSCustomObject]@{
                    DeviceId  = '\\?\Volume{asdfsdf}\'
                    DriveType = 2
                }
            }
            $Cmd = Get-FslDriveType 0
            $Cmd | should be 'Fixed'

        }
        it 'Network'{
            mock -CommandName Get-WmiObject -mockwith{
                [PSCustomObject]@{
                    DeviceId  = '\\?\Volume{asdfsdf}\'
                    DriveType = 3
                }
            }
            $Cmd = Get-FslDriveType 0
            $Cmd | should be 'Network'
        }
        it 'CD-ROM'{
            mock -CommandName Get-WmiObject -mockwith{
                [PSCustomObject]@{
                    DeviceId  = '\\?\Volume{asdfsdf}\'
                    DriveType = 4
                }
            }
            $Cmd = Get-FslDriveType 0
            $Cmd | should be 'CD-ROM'
        }
        it 'RAM Disk'{
            mock -CommandName Get-WmiObject -mockwith{
                [PSCustomObject]@{
                    DeviceId  = '\\?\Volume{asdfsdf}\'
                    DriveType = 5
                }
            }
            $Cmd = Get-FslDriveType 0
            $Cmd | should be 'RAM Disk'
        }
    }
}