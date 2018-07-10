function move-FslDiskContents {
    <#
        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER VHDPath
        Path to a specified VHD

        .PARAMETER FilePath
        Optional file path within a VHD.

        .PARAMETER Destination
        Destination for file content transfer.

        .PARAMETER Overwrite
        Overwrite any pre-existing files in destination directory that are the same name
        as the files from the VHD.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("path")]
        [System.string]$VhdPath,

        [Parameter(Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
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
                            Write-Warning "File: $($file.name) already exists here. Skipping..."
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