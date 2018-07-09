function Format-FslDriveLetter {
    <#
        .SYNOPSIS
        Function to either get, set, or remove a disk's driveletter.

        .PARAMETER VHDpath
        Path to a specificed VHD or directory of VHD's.

        .PARAMETER Command
        User command to either get a driveletter, set a driveletter, or remove a driveletter.

        .PARAMETER Letter
        Letter to assign if user opts to set a drive letter

        .EXAMPLE
        format-fsldriveletter -path C:\users\danie\documents\ODFC\test1.vhd -command get
        Get's the associated driveletter on test1.vhd

        .EXAMPLE
        format-fsldriveletter -path C:\users\danie\documents\ODFC\test1.vhd -command set -letter T
        Assigns drive letter 'T' to test1.vhd

        .EXAMPLE
        format-fsldriveletter -path C:\users\danie\documents\ODFC\test1.vhd -command remove
        Remove's the driveltter on test1.vhd
    #>
    [CmdletBinding()]
    param (
        
        [Parameter(Position = 0, Mandatory = $true, 
        ValueFromPipeline = $true)]
        [alias("path")]
        [System.String]$VhdPath,
        
        [Parameter(Position = 1, Mandatory = $true, 
        ValueFromPipeline = $true)]
        [ValidateSet('get','set','remove')]
        [System.String]$Command,

        [Parameter(Position = 2, Mandatory = $false, 
        ValueFromPipeline = $true)]
        [ValidatePattern('^[a-zA-Z]')]
        [System.Char]$Letter


    )
    
    begin {
        set-strictmode -Version latest
        $GetDL = $false
        $SetDL = $false
        $RemoveDL = $false
    }
    
    process {
        ## Helper function to retrieve VHD's. Will handle errors ##
        $VHDs = get-fslvhd -Path $VhdPath
        
        switch ($Command) {
            'get' {
                $GetDL = $true
            }
            'set' {
                $SetDL = $true
                if($null -eq $Letter){
                    Write-Warning "Please enter a Drive Letter. Example: Format-FslDriveLetter -Command 'set' -Letter 'G'" -WarningAction Stop
                }
            }
            'remove' {
                $RemoveDL = $true
            }
        }

        ## Helper functions, Get-DriveLetter, Set-FslDriveletters, remove-fslDriveletter, and dismount-fsldisk
        ## Will validate error handling.

        foreach ($vhd in $VHDs) {
 
            if ($GetDL) {
                get-driveletter -VHDPath $vhd.path
                dismount-FslDisk -path $vhd.path
            }
            if ($SetDL) {
                Set-FslDriveLetter -VHDPath $vhd.path -Letter $letter
            }
            if ($RemoveDL) {
                Remove-FslDriveLetter -Path $vhd.path
            }
        }
    }
    
    end {
    }
}