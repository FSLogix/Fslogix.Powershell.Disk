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


    #>

    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.string]$path,

        [Parameter(Position = 1)]
        [Switch]$Remove,

        [Parameter(Position = 2)]
        [Switch]$output,

        [Parameter(Position = 3)]
        [Switch]$full
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
        $VHDs = get-fslvhd -path $path

        foreach ($vhd in $VHDs) {
            $DriveLetter = get-driveletter -path $vhd.path
            $osts = get-childitem -path (join-path $DriveLetter *.ost) -recurse

            if ($null -eq $osts) {
                Write-Warning "Could not find OSTs in $($vhd.path)"
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

            if($full){
                foreach($ost in $osts){
                    Write-Verbose "$(Get-Date): OST located at: $ost"
                }
            }

            if($output){
                Write-Output $osts
            }

            ## If user wants to delete Osts ##
            if ($count -gt 1) {
                if ($Remove) {
                    $latestOst = $osts | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1

                    try {
                        $osts | Where-Object {$_.Name -ne $latestOst.Name} | Remove-Item -Force -ErrorAction Stop
                        $Totalremoved += $($count - 1)
                        Write-Verbose "$(Get-Date): Successfully removed duplicate ost files"
                    }
                    catch {
                        Write-Error $Error[0]
                    }

                    Write-Verbose "$(Get-Date): Removed $TotalRemoved OST's"
                }

            }else{
                Write-Verbose "$(Get-Date): Only one OST found. SKipping deletion."
            }
            try {
                ## Helper function dismount-fsldisk ##
                dismount-FslDisk -path $vhd.path
            }
            catch {
                Write-Error $Error[0]
            }
        }#foreach

    }

    end {
    }
}