function move-FslDiskContents {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [Alias("path")]
        [System.string]$VhdPath,

        [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true)]
        [System.String]$FilePath,

        [Parameter(Position = 2, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$Destination,

        [Parameter(Position = 3, Mandatory = $true)]
        [Validateset("yes", "no")]
        [System.string]$Overwrite
    )
    
    begin {
        ## Helper function to validate requirements
        Get-Requirements

        Write-Verbose "Begining script.."
    }
    
    process {

        if (-not(test-path -path $VhdPath)) {
            write-error "Could not validate VHd path: $vhdpath"
            exit
        }
        if (-not(test-path -path $Destination)) {
            write-error "Could not validate destination: $Destination"
            exit
        }

        ## Using get-fsldisk rather than get-fslVHD because this function's script
        ## should only get an user input of a specified VHD rather than directory
        ## Get-fsldisk helper function will validate the user's input
        $VHD = get-fsldisk -path $VhdPath

        $name = split-path -Path $VHD.path -leaf

        if ($VHD.attached) {
            Write-error "VHD: $name is currently in use."
            exit
        }

        $DriveLetter = get-driveletter -path $VHD.path
        $VHD_File = join-path($DriveLetter) ($FilePath)

        if (-not(test-path -path $VHD_File)) {
            write-error "Path: $VHD_File is not valid."
            dismount-FslDisk -path $VHD.path
        }

        $Contents = get-childitem -path $VHD_File
        
        if ($null -eq $Contents) {
            Write-Warning "Could not find any files in $VHD_FIle"
        }
        else {
            foreach($file in $Contents){
                $check = get-childitem -path $Destination | Where-Object {$_.Name -eq $file.Name}
                if($check){
                    switch($Overwrite){
                        "Yes"{
                            move-item -path $file.fullname -Destination $Destination -Force
                        }
                        "No"{
                            Write-Warning "User opted to not overwrite. Sipping file."
                        }
                    }
                }else{
                    move-item -path $file.fullname -Destination $Destination -Force
                }
            }
        }
        Write-Verbose "Finished getting disk contents."
        dismount-FslDisk -path $VhdPath
    }
    
    end {
    }
}