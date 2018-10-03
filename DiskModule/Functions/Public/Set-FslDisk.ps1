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
                    Mandatory = $true,
                    ParameterSetName = "Name")]
        [System.String]$Name,

        [Parameter( Position = 3, 
                    ValuefromPipeline = $true,
                    ValuefromPipelineByPropertyName = $true, 
                    ParameterSetName = "Name")]
        [regex]$OriginalMatch = "^(.*?)_S-\d-\d+-(\d+-){1,14}\d+$",

        [Parameter( Position = 4, 
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

        if(!$PSBoundParameters.ContainsKey("Path")){
            Write-Error "Must specify a path to VHD" -ErrorAction Stop
        }
        if(-not(test-path -path $Path -ErrorAction Stop)){
            Write-Error "Could not find path: $Path" -ErrorAction Stop
        }else{
            $VHD = Get-Fsldisk -Path $Path
        }

        Switch ($PSBoundParameters.Keys){
            Label{
                $DriveLetter = Get-FslDriveletter -Path $Path
                if($null -eq $DriveLetter){
                    Write-Error "Could not find driveletter for $($VHD.name)" -ErrorAction Stop
                }

                $Volume = Get-Volume | where-object {$_.DriveLetter -eq $DriveLetter.substring(0,1)}
                Try{
                    $Volume | Set-Volume -NewFileSystemLabel $Label -ErrorAction Stop
                }catch{
                    Write-Error $Error[0]
                }
                Write-Verbose "Set $($VHD.name)'s label to: $Label"
            }
            Name{

                if($Name -notmatch $OriginalMatch){
                    Write-Error "$Name does not match Syntax." -ErrorAction Stop
                }
                if($Name -notmatch $FlipFlopMatch){
                    Write-Error "$Name does not match Syntax." -ErrorAction Stop
                }

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
                    Write-Verbose "$($VHD.name) to $Name"
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