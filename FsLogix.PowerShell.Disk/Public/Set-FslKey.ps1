function Set-FslKey {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, 
            Mandatory = $true, 
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true
        )][System.String]$Key       
    )
    
    begin {
        set-strictmode -version latest
    }
    
    process {
    }
    
    end {
    }
}