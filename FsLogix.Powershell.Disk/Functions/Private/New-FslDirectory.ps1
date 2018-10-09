function New-FslDirectory {
    [CmdletBinding()]
    param (
        [Parameter (Position = 0,
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [String]$SamAccountName,

        [Parameter (Position = 1,
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [String]$SID,

        [Parameter (Position = 2,
                    Mandatory = $True,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [String]$Destination,

        [Parameter (Position = 3)]
        [Switch]$FlipFlop,

        [Parameter (Position = 4)]
        [Switch]$Passthru
    )
    
    begin {
        Set-StrictMode -Version Latest
        #Requires -RunAsAdministrator
        #Requires -Modules "ActiveDirectory"
    }
    
    process {
        
        if($PSBoundParameters.ContainsKey("FlipFlop")){
            $User_Dir_Name = $SID + "_" + $SamAccountName
        }else{
            $User_Dir_Name = $SamAccountName + "_" + $SID
        }

        if($Destination.ToLower().Contains("%username%")){
            $Directory = $Destination -replace "%Username%", $User_Dir_Name
        }else{
            $Directory = join-path ($Destination) ($User_Dir_Name)
        }

        if(test-path -path $Directory){
            Remove-item -Path $Directory -Force -Recurse -ErrorAction SilentlyContinue
        }

        Try{
            New-Item -path $Directory -ItemType Directory -Force -ErrorAction Stop | out-null
        }catch{
            Write-Error $Error[0]
        }

        if($PSBoundParameters.ContainsKey("Passthru")){
            $Directory
        }
    }
    
    end {
    }
}