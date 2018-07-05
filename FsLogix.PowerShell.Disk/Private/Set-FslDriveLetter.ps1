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
        $Letters = [int]'A'[0]..[int]'Z'[0] | Foreach-Object {$([char]$_)}
        $Drives = Get-PSDrive | Where-Object {$_.Provider.Name -eq 'FileSystem'}
        $Free_DriveLetters = $Letters | Where-Object {$_ -notin $Drives.Name} 
            
        $NewLetter = "$Letter" + ":"
        $Available = $false
        foreach ($curLetter in $Free_DriveLetters) {
            if ($curLetter.ToString() -eq $Letter) {
                $Available = $true
                break
            }
        }

        if($Available -eq $false){
            Write-Warning "DriveLetter $Letter is not available. Please use a different letter."
            exit
        }

        foreach ($vhd in $VHDs) {
            $name = split-path -path $vhd.path -leaf
            $DL = Get-driveletter -VHDPath $vhd.path
            $subbedDL = $DL.substring(0,2)
    
            try {
                Write-Verbose "Getting $name's volume: DL = $DL"
                $drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = '$subbedDl'"
            }
            catch {
                Write-Error $Error[0]
                exit
            }
    
            Write-Verbose "Assigning new driveletter: $NewLetter"
                
            try {
                $drive | Set-WmiInstance -Arguments @{DriveLetter = $NewLetter} -ErrorAction Stop | out-null
            }
            catch {
                Write-Error $Error[0]
                Write-Error "The Drive Letter: $Letter, might already be mapped and in use."
                exit
            }

            Write-Verbose "Succesfully changed $name's Driveletter to $letter."
            dismount-FslDisk -path $Vhd.path
        }
    }  
    end {
    }
}