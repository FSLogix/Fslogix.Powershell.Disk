function Set-FslDriveLetter {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$VHDPath,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidatePattern('^[a-zA-Z]')]
        [System.Char]$Letter
    )
    
    begin {
        Set-StrictMode -Version latest
    }
    
    process {
        
        $VHDs = Get-FslVHD -path $VHDPath
        if ($null -eq $VHDs) {
            Write-Warning "Could not find any VHD's in path: $VHDPath"
            exit
        }

        foreach ($vhd in $VHDs) {
            $name = split-path -path $vhd.path -leaf

            try{
                Write-Verbose "Getting $name's volume"
                $DL = Get-driveletter -VHDPath $vhd.path
                $drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = '$($DL.substring(0,2))'"
            }catch{
                Write-Error $Error[0]
                exit
            }

            try{
                Write-Verbose "Assigning new driveletter: $letter"
                Set-WmiInstance -input $drive -Arguments @{DriveLetter="$($Letter):"; Label="Label"}
            }catch{
                Write-Error $Error[0]
                exit
            }

            Write-Verbose "Succesfully changed $name's Driveletter to $letter."
            dismount-FslDisk -path $Vhd.path
        }
        
        
    }
    
    end {
    }
}