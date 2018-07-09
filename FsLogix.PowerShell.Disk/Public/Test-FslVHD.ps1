function Test-FslVHD {
    <#
        .SYNOPSIS 
        Returns if VHD is valid or contains any problems. 
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.string]$path
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {

        if(-not(test-path -Path $path)){
            Write-Error "Could not find path: $path" -ErrorAction Stop
        }

        ## Helper function Get-FslVHD/Get-FslDisk will help handle error cases"
       
        $VHDs = Get-FslVHD -path $path
    
        foreach($vhd in $VHDs){
            $Name = split-path -path $vhd.path -leaf
            $output = Test-VHD -path $vhd.path
            if($output){
                Write-Output $output
                Write-Verbose "$Name is healthy"
            }else{
                Write-Warning "$name is unhealthy"
            }
        }
    }
    
    end {
    }
}