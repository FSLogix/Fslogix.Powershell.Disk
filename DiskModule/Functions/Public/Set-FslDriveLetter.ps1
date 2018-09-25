function Set-FslDriveLetter {
    [CmdletBinding()]
    param (
        [Parameter( Position = 0, 
                    Mandatory = $true, 
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [System.String]$Path,

        [Parameter( Position = 1, 
                    Mandatory = $true, 
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [ValidatePattern('^[a-zA-Z]')]
        [System.Char]$Letter,

        [Parameter( Position = 2)]
        [Switch]$Dismount
    )

    begin {
        Set-StrictMode -Version Latest
        #Requires -RunAsAdministrator
        function Get-FslAvailableDriveLetter {
 
            Param(
                [Parameter(Position = 0)]
                [Switch]$Next
            )
            ## Start at D rather than A since A-B are floppy drives and C is used by main operating system.
            $Letters = [char[]](68..90)
            $AvailableLetters = New-Object System.Collections.ArrayList
            foreach ($letter in $Letters) {
                $Used_Letter = Get-PsDrive -Name $letter -ErrorAction SilentlyContinue
                if ($null -eq $Used_Letter) {
                    $null = $AvailableLetters.add($letter)
                }
            }
        
            if ($Next) {
                Write-Output $AvailableLetters | select-object -first 1
            }
            else {
                Write-Output $AvailableLetters
            }
         
        }
        
        
    }

    process {

        if (-not(test-path -path $Path)) {
            Write-Error "Could not find path: $Path" -ErrorAction Stop
        }

        $VHDs = Get-FslDisk -path $Path
        if ($null -eq $VHDs) {
            Write-Warning "Could not find any VHD's in path: $Path" -WarningAction Stop
        }

        $AvailableLetters = Get-FslAvailableDriveLetter

        $Available = $false

        if ($AvailableLetters -contains $Letter) {
            $Available = $true
        }

        if ($Available -eq $false) {
            Write-Warning "For available driveletters, type cmdlet: Get-FslAvailableDriveLetter"
            Write-Error "DriveLetter '$($Letter):\' is not available. " -ErrorAction Stop
        }
        $name = $vhds.name
        if ($vhds.attached) {
            $Disk = get-disk | where-object {$_.Location -eq $Path}
        }
        else {
            $mount = Mount-DiskImage -ImagePath $path -NoDriveLetter -PassThru -ErrorAction Stop | get-diskimage
            $Disk = $mount | get-disk -ErrorAction Stop
        }
        $Partition = $Disk | get-partition -ErrorAction Stop
        $Partition | sort-object -property size | select-object -last 1 | set-partition -NewDriveLetter $letter -ErrorAction Stop 

        Write-Verbose "Succesfully changed $name's Driveletter to [$($letter):\]."
        
        if ($Dismount) {
            Try {
                Dismount-DiskImage -ImagePath $Path
            }
            catch {
                Write-Error $Error[0]
            }
        }
    
    }
    end {
    }
}