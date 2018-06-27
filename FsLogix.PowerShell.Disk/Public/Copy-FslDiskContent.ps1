function Copy-FslDiskContent {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("VHD1")]
        [System.String]$FirstVHDPath,

        [Parameter(Position = 1, Mandatory = $false)]
        [Alias("File")]
        [System.string]$FirstFilePath,

        [Parameter(Position = 2, Mandatory = $true)]
        [Alias("VHD2")]
        [System.String]$SecondVHDPath,

        [Parameter(Position = 3, Mandatory = $false)]
        [Alias("File2")]
        [System.String]$SecondFilePath
    )
    
    begin {
        ## Helper function to validate requirements
        Get-Requirements

        #If paths are invalid, get-driveletter script will handle it        
        $First_DL = get-driveletter -path $FirstVHDPath
        $Second_DL = get-driveletter -path $SecondVHDPath

        $FirstVHD = split-path $FirstVHDPath -Leaf
        $SecondVHD = split-path $SecondVHDPath -leaf

        $FirstFilePath = join-path($First_DL) ($FirstFilePath)
        $SecondFilePath = join-path($Second_DL) ($SecondFilePath)
    }
    
    process {

        $Contents = get-childitem -path $FirstFilePath

        if (-not(test-path -path $FirstFilePath)) {
            write-error "Could not find path: $firstfilepath"
            exit
        }

        if ($Contents.Count -eq 0) {
            Write-Error "No Files found in $FirstFilePath"
            exit
        }

        if (-not(test-path -path $SecondFilePath)) {
            write-error "Could not find path: $SecondFilePath"
            exit
        }

        $Contents | ForEach-Object { 

            try {
                Write-Verbose "Copying VHD:$firstVHD $($_.fullname) to VHD: $secondVHD $secondfilepath"
                Copy-Item -path $_.FullName -Destination $SecondFilePath -Recurse -Force
            }
            catch {
                Write-Error $Error[0]
            }
        }#foreach

        $FirstVHDPath | dismount-FslDisk
        $SecondVHDPath | dismount-FslDisk
      
    }
    
    end {
        Write-Verbose "Finshed copying contents."
    }
}