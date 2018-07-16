function Get-FslOstFile {

    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.string]$path,

        [Parameter(Position = 1)]
        [Switch]$Remove,

        [Parameter(Position = 2)]
        [Switch]$output
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
                Write-Verbose "$(Get-Date): Retrieved $count Osts in $($vhd.path)"
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