function Copy-FslDiskContent {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("VHD1")]
        [System.String]$FirstVHDPath,

        [Parameter(Position = 1)]
        [Alias("File")]
        [System.string]$FirstFilePath,

        [Parameter(Position = 2, Mandatory = $true)]
        [Alias("VHD2")]
        [System.String]$SecondVHDPath,

        [Parameter(Position = 3)]
        [Alias("File2")]
        [System.String]$SecondFilePath,

        [Parameter(Position = 4)]
        [Switch]$Overwrite
    )
    
    begin {
        ## Helper function to validate requirements
        set-strictmode -Version latest
        #If paths are invalid, get-driveletter script will handle it        
        $First_DL = get-driveletter -path $FirstVHDPath
        $Second_DL = get-driveletter -path $SecondVHDPath

        $FirstVHD = split-path $FirstVHDPath -Leaf
        $SecondVHD = split-path $SecondVHDPath -leaf

        $FirstFilePath = join-path($First_DL) ($FirstFilePath)
        $SecondFilePath = join-path($Second_DL) ($SecondFilePath)
    }
    
    process {
        if (-not(test-path -path $FirstFilePath)) {
            write-error "Could not find path: $firstfilepath" -ErrorAction Stop
        }
        if (-not(test-path -path $SecondFilePath)) {
            write-error "Could not find path: $SecondFilePath" -ErrorAction Stop
        }

        $Contents = get-childitem -path $FirstFilePath
        if ($Contents.Count -eq 0) {
            Write-Error "No Files found in $FirstFilePath" -ErrorAction Stop
        }

        $Contents | ForEach-Object { 

            if ($Overwrite) {
                Copy-Item -path $_.FullName -Destination $SecondFilePath -Recurse -Force
                Write-Verbose "Successfully copied and overwritten VHD:$firstVHD $($_.fullname) to VHD: $secondVHD $secondfilepath"
            }else{
                Copy-Item -path $_.FullName -Destination $SecondFilePath -Recurse -ErrorAction Stop
                Write-Verbose "Successfully Copied VHD:$firstVHD $($_.fullname) to VHD: $secondVHD $secondfilepath"
            }
           
        }#foreach

        $FirstVHDPath | dismount-FslDisk
        $SecondVHDPath | dismount-FslDisk
      
    }
    
    end {
    }
}