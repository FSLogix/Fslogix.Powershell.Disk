function move-FslDiskContents {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("path")]
        [System.string]$VhdPath,

        [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$FilePath,

        [Parameter(Position = 2, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$Destination,

        [Parameter(Position = 3)]
        [Switch]$Overwrite
    )
    
    begin {
    }
    
    process {

        if (-not(test-path -path $VhdPath)) {
            write-error "Could not validate VHd path: $vhdpath" -ErrorAction Stop
        }
        if (-not(test-path -path $Destination)) {
            write-error "Could not validate destination: $Destination" -ErrorAction Stop
        }
        
        $VHD = get-fsldisk -path $VhdPath

        $DriveLetter = get-driveletter -path $VHD.path
        $VHD_File = join-path($DriveLetter) ($FilePath)

        if (-not(test-path -path $VHD_File)) {
            write-error "Path: $VHD_File is not valid." -ErrorAction Stop
        }

        $Contents = get-childitem -path $VHD_File
        
        if ($null -eq $Contents) {
            Write-Warning "Could not find any files in $VHD_FIle" -WarningAction Stop
        }
        else {
            foreach($file in $Contents){
                $check = get-childitem -path $Destination | Where-Object {$_.Name -eq $file.Name}
                if($check){
                    switch($Overwrite){
                        "Yes"{
                            move-item -path $file.fullname -Destination $Destination -Force
                            Write-Verbose "Moved $($file.name) to $Destination"
                        }
                        "No"{
                            Write-Warning "User opted to not overwrite. Sipping file."
                        }
                    }
                }else{
                    move-item -path $file.fullname -Destination $Destination -Force
                    Write-Verbose "Moved $($file.name) to $Destination"
                }
            }
        }
        dismount-FslDisk -path $VhdPath
    }
    
    end {
    }
}