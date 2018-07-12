function Remove-FslDisk {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$path
    )

    begin {
        set-strictmode -Version latest
    }

    process {
        if(-not(test-path -path $path)){
            Write-Error "Could not find path: $path" -ErrorAction Stop
        }

        $VHDs = Get-FslVHD -path $path

        foreach($vhd in $VHDs){
            try{
                remove-item -path $vhd.path
                Write-Verbose "Removed $(split-path -path $vhd.path -leaf)"
            }catch{
                Write-Error $Error[0]
            }
        }
    }

    end {
    }
}