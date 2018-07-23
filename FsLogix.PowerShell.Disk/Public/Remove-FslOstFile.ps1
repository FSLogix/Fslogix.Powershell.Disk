function Remove-FslOstFile {
    [CmdletBinding(DefaultParameterSetName = 'none')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [System.String]$path,

        [Parameter(Position = 1)]
        [Switch]$full,

        [Parameter(Position = 2,ParameterSetName = 'index', Mandatory = $true)]
        [int]$Start,

        [Parameter(Position = 3,ParameterSetName = 'index', Mandatory = $true)]
        [int]$End
    )

    begin {
        set-strictmode -Version latest
    }

    process {
        if(-not(test-path $path)){
            Write-Error "Could not find path: $path" -ErrorAction Stop
        }
        if($full){
            get-fslostfile -path $path -remove -full -Start $Start -End $End
        }else{
            get-fslostfile -path $path -remove -Start $Start -End $end
        }
    }

    end {
    }
}