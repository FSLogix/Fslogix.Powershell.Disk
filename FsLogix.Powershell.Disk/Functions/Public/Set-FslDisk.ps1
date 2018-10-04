function Set-FslDisk {
    [CmdletBinding(DefaultParameterSetName = "None")]
    param (
        [Parameter( Position = 0,
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [System.String]$Path,

        [Parameter (Position = 1,
                    Mandatory = $true,
                    ParameterSetName = "Label")]
        [System.String]$Label,

        [Parameter (Position = 2,
                    ParameterSetName = "Label")]
        [Switch]$Assign,

        [Parameter (Position = 3,
                    Mandatory = $true,
                    ParameterSetName = "Name")]
        [System.String]$Name,

        [Parameter( Position = 4, 
                    ValuefromPipeline = $true,
                    ValuefromPipelineByPropertyName = $true, 
                    ParameterSetName = "Name")]
        [regex]$OriginalMatch = "^(.*?)_S-\d-\d+-(\d+-){1,14}\d+$",

        [Parameter( Position = 5, 
                    ValuefromPipeline = $true,
                    ValuefromPipelineByPropertyName = $true, 
                    ParameterSetName = "Name")]
        [regex]$FlipFlopMatch = "S-\d-\d+-(\d+-){1,14}\d+\.*?"

        <#
        
            Size?
            Partition Size?
            VHD, VHDx?
        
        #>
    )
    
    begin {
        Set-Strictmode -Version Latest
        #Requires -RunAsAdministrator
    }
    
    process {

        if(-not(test-path -path $Path -ErrorAction Stop)){
            Write-Error "Could not find path: $Path" -ErrorAction Stop
        }
            
        Try{
            $VHD = Get-Fsldisk -Path $Path -ErrorAction Stop
        }catch{
            Write-Error $Error[0]
        }

        Switch ($PSBoundParameters.Keys){
            Label{
                $DriveLetter = Get-FslDriveletter -Path $Path
                if($null -eq $DriveLetter){
                    if($PSBoundParameters.ContainsKey("Assign")){
                        $DriveLetter = Add-FslDriveLetter -Path $Path -Passthru
                    }else{
                        Write-Error "Could not find driveletter for $($VHD.name)" -ErrorAction Stop
                    }
                }

                $Volume_DriveLetter = $DriveLetter.substring(0,1)

                Try{
                    Set-Volume -DriveLetter $Volume_DriveLetter -NewFileSystemLabel $Label -ErrorAction Stop
                }catch{
                    Write-Error $Error[0]
                }
                Write-Verbose "Set $($VHD.name)'s label to: $Label"
            }
            Name{
                if($Name -notmatch $OriginalMatch){
                    Write-Warning "$Name does not match original regex. Attempting FlipFlop match."
                    if($Name -notmatch $FlipFlopMatch){
                        Write-Error "$Name does not match Syntax." -ErrorAction Stop
                    }
                }
                ## What should the name be. CDW had name of 'ODFC_SamAccountName'
                ## so is the regex match for SID_Name or Name_SID neccessary?
                
                #Can't rename if VHD is attached
                if($VHD.attached){
                    Try{
                        Dismount-DiskImage -ImagePath $Path
                    }catch{
                        Write-Error $Error[0]
                    }
                }
                
                try{
                    Rename-Item -Path $Path -NewName $Name -ErrorAction Stop
                    Write-Verbose "Renamed $($VHD.name) to $Name"
                }
                catch{
                    Write-Error $Error[0]
                }
            }
        }
    }
    
    end {
    }
}