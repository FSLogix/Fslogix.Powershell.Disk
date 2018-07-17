function Remove-FslOstFile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [System.String]$path,

        [Parameter(Position = 1)]
        [Switch]$full
    )

    begin {
        set-strictmode -Version latest
    }

    process {
        if(-not(test-path $path)){
            Write-Error "Could not find path: $path" -ErrorAction Stop
        }
        if($full){
            get-fslostfile -path $path -remove -full
        }else{
            get-fslostfile -path $path
        }
    }

    end {
    }
}