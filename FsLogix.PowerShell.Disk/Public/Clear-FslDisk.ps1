function Clear-FslDisk {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$path,

        [Parameter(Position = 1)]
        [System.String]$folder
    )

    begin {
        set-strictmode -Version latest
    }

    process {
        if(-not(test-path $path)){
            Write-Error "Could not find path: $Path" -ErrorAction Stop
        }

        ## Helper function ##
        $VHDs = get-fslvhd -path $path

        foreach($vhd in $VHDs){

            ## Helper function ##
            $contents = Get-fsldiskcontents -VHDPath $vhd.path
            Write-Verbose "Retreived contents"
            if($null -eq $contents){
                Write-Warning "$(split-path $vhd.path -leaf) is already cleared."
                continue
            }

            try{
                $contents | remove-item -Recurse
            }catch{
                Write-Error $Error[0]
            }

            Write-Verbose "Succesfully cleared $(split-path $vhd.path -leaf)"
            dismount-FslDisk

        }#foreach
    }

    end {
    }
}
