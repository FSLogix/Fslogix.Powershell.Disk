function Format-FslDriveLetter {
    [CmdletBinding()]
    param (
        
        [Parameter(Position = 0, Mandatory = $true, 
        ValueFromPipeline = $true)]
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
        $VHDs = get-fsldisk -Path $VhdPath
        
        switch ($Command) {
            'get' {
                $GetDL = $true
            }
            'set' {
                $SetDL = $true
                if($null -eq $Letter){
                    Write-Warning "Please enter a Drive Letter. Example: Format-FslDriveLetter -Command 'set' -Letter 'G'"
                    exit
                }
            }
            'remove' {
                $RemoveDL = $true
            }
        }

        ## Helper functions, Get-DriveLetter, Set-FslDriveletters, remove-fslDriveletter, and dismount-fsldisk
        ## Will validate error handling.

        foreach ($vhd in $VHDs) {
            $name = split-path -Path $vhd.path
            Write-Verbose "Processing VHD: $name"
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
            Write-Verbose "Finished Processing VHD: $name"
        }
    }
    
    end {
    }
}