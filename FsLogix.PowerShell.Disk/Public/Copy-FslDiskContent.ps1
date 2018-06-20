function Copy-FslDiskContent {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("VHD1")]
        [System.String]$FirstVHDPath,

        [Parameter(Position = 1, Mandatory = $true)]
        [Alias("File")]
        [System.string]$FirstFilePath,

        [Parameter(Position = 2, Mandatory = $true)]
        [Alias("VHD2")]
        [System.String]$SecondVHDPath,

        [Parameter(Position = 3, Mandatory = $true)]
        [Alias("File2")]
        [System.String]$SecondFilePath
    )
    
    begin {
    
        set-strictmode -version latest

        #If paths are invalid, Mount-fslvhd script will handle it        
        $First_DL = mount-FSLVHD -path $FirstVHDPath
        $Second_DL = mount-FSLVHD -path $SecondVHDPath

        $FirstFilePath = join-path($First_DL) ($FirstFilePath)
        $SecondFilePath = join-path($Second_DL) ($SecondFilePath)
    }
    
    process {

        $Contents = get-childitem -path $FirstFilePath
        if($Contents.Count -eq 0){
            Write-Error "No Files found in $FirstFilePath"
            exit
        }

        if(-not(test-path -path $SecondFilePath)){
            write-error "Could not find path: $SecondFilePath"
            exit
        }

        $Contents | ForEach-Object { 

            try {
                Copy-Item -path $_.FullName -Destination $SecondFilePath -Recurse -Force
            }
            catch {
                Write-Error $Error[0]
            }
        }#foreach

        dismount-FslVHD -path $FirstVHDPath
        dismount-FslVHD -path $SecondVHDPath
    }
    
    end {
        Write-Verbose "Finshed copying contents."
    }
}