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

        [Parameter (Position = 1,
                    Mandatory = $true,
                    ParameterSetName = "Name")]
        [System.String]$Name,

        [Parameter (Position = 1,
                    Mandatory = $true,
                    ParameterSetName = "Size")]
        [uint64]$size,

        [Parameter (Position = 1,
                    Mandatory = $true,
                    ParameterSetName = "vhdx")]
        [Switch]$vhdx,

        [Parameter (Position = 1,
                    Mandatory = $true,
                    ParameterSetName = "Vhd")]
        [Switch]$vhd
    )
    
    begin {
        Set-Strictmode -Version Latest
        #Requires -RunAsAdministrator
    }
    
    process {

        if(-not(test-path -path $Path -ErrorAction Stop)){
            Write-Error "Could not find path: $Path" -ErrorAction Stop
        }
       
        $VHDinfo = Get-Fsldisk -Path $Path -ErrorAction Stop
    
        Switch ($PSBoundParameters.Keys){
            Label{
                Try{
                    Set-FslLabel -Path $Path -Label $Label -ErrorAction Stop
                }catch{
                    Write-Error $Error[0]
                }
                if($Assign){
                    Try{
                        Add-FslDriveLetter -Path $Path -ErrorAction Stop
                    }catch{
                        Write-Error $Error[0]
                    }
                }
            }
            Name{
                ## What should the name be. CDW had name of 'ODFC_SamAccountName'
                ## so is the regex match for SID_Name or Name_SID neccessary?
                
                #Can't rename if VHD is attached
                if($VHDinfo.attached){
                    Try{
                        Dismount-DiskImage -ImagePath $Path
                    }catch{
                        Write-Error $Error[0]
                    }
                }
                
                try{
                    Rename-Item -Path $Path -NewName $Name -ErrorAction Stop
                    Write-Verbose "Renamed $($VHDinfo.name) to $Name"
                }
                catch{
                    Write-Error $Error[0]
                }
            }
            Size {
                # Resize VHD
            }
            
            VHDx {
                # Convert to VHDx
            }

            VHD {
                # Convert to VHD
            }
        }
    }
    
    end {
    }
}