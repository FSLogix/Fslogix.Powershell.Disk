function Test-FslVHD {
    <#
        .SYNOPSIS 
        Tests if VHD is valid or contains any problems.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.string]$path
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {

        Write-Verbose "Validating path: $path"
        if(-not(test-path -Path $path)){
            Write-Error "Could not find path: $path"
            exit
        }
        Write-Verbose "Validated Path: $path"

        Write-Verbose "Retrieving VHD(s)"
        $VHDs = Get-FslVHD -path $path
        if($null -eq $VHDs){
            Write-Error "Could not find any VHD(s) in $path"
        }
        Write-Verbose "Retrieved VHD(s)"

        Write-Verbose "Testing VHD(s)"
        foreach($vhd in $VHDs){
            $Name = split-path -path $vhd.path -leaf
            if(Test-VHD -path $vhd.path){
                Write-Verbose "$Name is healthy"
            }else{
                Write-Warning "$name is unhealthy"
            }
        }
        Write-Verbose "Finised Testing. Exiting script..."
        
    }
    
    end {
    }
}