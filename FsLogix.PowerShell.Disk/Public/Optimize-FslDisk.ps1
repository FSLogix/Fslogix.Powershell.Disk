function Optimize-FslDisk {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.string]$path,

        [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true)]
        [Validateset('full','retrim','quick')]
        [System.String]$mode = 'quick'
    )
    
    begin {
        ## Fsl helper function ##
        get-requirements
    }
    

    
    process {
        if(-not(test-path $path)){
            Write-Error "Could not find path: $path"
        }else{
            $VHD = Get-FslDisk -path $path
        }
        if($VHD.Vhdtype -eq 'fixed'){
            Write-Error "VHD cannot be of type: 'fixed'. Must be dynamic"
            exit
        }

        ## Remove Duplicates ##
        get-FslDuplicateFiles -path $path -csvpath 'test.csv' -Remove 'true'
        ## Removed Duplicates

        try{
            Write-Verbose "Optimizing VHD: $path"
            Optimize-VHD -Path $path -Mode $mode
        }catch{
            Write-Error $Error[0]
        }
    }
    
    end {
    }
}