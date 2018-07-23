function Get-FslOstFile {
    <#
        .SYNOPSIS
        Returns the OST files within a disk

        .PARAMETER Path
        Path to a specified disk or directory.

        .PARAMETER Remove
        User's option to have duplicate ost's removed

        .PARAMETER Output
        User's option to have the ost's information outputted to pipeline

        .PARAMETER Full
        User's option to have OST's path outputted

        .EXAMPLE
        Get-FslOstFile -path 'C:\users\test.vhd'
        Returns the ost's found in test.vhd

        .EXAMPLE
        Get-FslOstFile -path 'C:\users\test.vhd' -full
        Returns the ost's found in test.vhd and their location

        .EXAMPLE
        Get-FslOstFile -path 'C:\users\test.vhd' -remove
        Removes any duplicate osts found in test.vhd

        .EXAMPLE
        Get-FslOstFile -path 'C:\users\test.vhd' -output
        Outputs the duplicate osts in test.vhd

        .EXAMPLE
        Get-FslOstFile -path 'C:\users\test' -remove
        Find's all the virtual disks in directory 'test' and removes the duplicate osts

    #>

    [CmdletBinding(DefaultParameterSetName = 'None')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.string]$path,

        [Parameter(Position = 1)]
        [Switch]$Remove,

        [Parameter(Position = 2)]
        [Switch]$output,

        [Parameter(Position = 3)]
        [Switch]$full,

        [Parameter(Position = 4, ParameterSetName = 'index', Mandatory = $true)]
        [int]$Start,

        [Parameter(Position = 5, ParameterSetName = 'index', Mandatory = $true)]
        [int]$End
    )

    begin {
        ## Helper function to validate requirements
        Set-StrictMode -Version latest
        $Totalremoved = 0
    }

    process {
        if (-not(test-path -path $path)) {
            Write-Error "Could not find path: $path" -ErrorAction Stop
        }

        ## Helper function get-fslvhd ##
        $VHDs = get-fslvhd -path $path -start $Start -end $End

        foreach ($vhd in $VHDs) {
            $removed = 0
            $DriveLetter = get-driveletter -path $vhd.path
            $osts = get-childitem -path (join-path $DriveLetter *.ost) -recurse

            if ($null -eq $osts) {
                Write-Warning "Could not find OSTs in $($vhd.path)"
                continue
            }
            else {
                try {
                    $count = $osts.count
                }
                catch [System.Management.Automation.PropertyNotFoundException] {
                    # When calling the get-childitem cmdlet, if the cmldet only returns one
                    # object, then it loses the count property, despite working on terminal.
                    $count = 1
                }
                Write-Verbose "$(Get-Date): Retrieved $count Ost(s) in $(split-path $vhd.path -leaf)"
            }

            if ($full) {
                foreach ($ost in $osts) {
                    Write-Verbose "$(Get-Date): OST located at: $ost"
                }
            }

            if ($output) {
                Write-Output $osts
            }

            if ($count -eq 1) {
                if ($Remove) {
                    Write-Verbose "$(Get-Date): Only 1 Ost, skipping deletion."
                }
            }

            ## If user wants to delete Osts ##
            if ($count -gt 1) {
                if ($Remove) {
                    $latestOst = $osts | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1

                    $osts | Where-Object {$_.Name -ne $latestOst.Name} | Remove-Item -Force -ErrorAction Stop
                    $removed += $($count - 1)
                    $Totalremoved += $($count - 1)
                    Write-Verbose "$(Get-Date): Successfully removed duplicate ost files"


                    Write-Verbose "$(Get-Date): Removed $Removed OST's"
                }
            }

            ## Helper function dismount-fsldisk ##
            dismount-FslDisk -path $vhd.path

        }#foreach
        Write-Verbose "Removed a total of: $TotalRemoved OST files."

    }

    end {
    }
}