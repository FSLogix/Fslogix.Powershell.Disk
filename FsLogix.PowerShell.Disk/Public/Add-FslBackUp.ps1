function Add-FslBackUp {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][System.String]$VHDName,

        [Parameter(Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][System.String]$Destination,

        [Parameter(Position = 2,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][Alias("Size")][int]$SizeInGB,

        [Parameter(Position = 3,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][System.String[]]$Directory,

        [Parameter(Position = 4,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][Switch]$VHD,

        [Parameter(Position = 5,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][Switch]$VHDx
    )

    begin {
        set-strictmode -Version latest
    }

    process {

        if($VHDName.Contains(".vhd") -or $VHDName.Contains(".vhdx")){
            $VHDName = [io.path]::GetFileNameWithoutExtension($VHDName)
        }

        ## If User did not specify VHD Name ##
        if ([System.String]::IsNullOrEmpty($VHDName)) {
            $VHDName = "BACKUP-$([datetime]::Today.ToString('MM-dd-yyyy'))"
        }

        ## If User did not specify Destination ##
        if ([System.String]::IsNullOrEmpty($Destination)) {
            $Destination = [Environment]::GetFolderPath("Desktop")
        }

        ## User specified they want vhd ##
        if ($VHD) {
            $VHDName += ".vhd"
        }
        ## User specified they want vhdx
        if ($VHDx) {
            $VHDName += ".vhdx"
        }

        ## User specified neither, defauled to vhdx
        if ((-not($VHD)) -and (-not($VHDx))) {
            $VHDName += ".vhdx"
        }

        if (test-path $Destination) {
            New-FslDisk -NewVHDPath $Destination -Name $VHDName -SizeInGB $SizeInGB -overwrite
        }
        else {
            Write-Error "Could not find destination: $Destination" -ErrorAction Stop
        }

        $New_VHD_Path = $Destination + "\" + $VHDName

        foreach($dir in $Directory){
            if(-not(test-path $dir)){
                Write-Error "Could not find path: $dir" -ErrorAction Continue
            }else{
                Write-Verbose "Backing up directory: $dir"
                try{
                    copy-FslToDisk -VhdPath $New_VHD_Path -FilePath $dir -recurse -Overwrite
                }catch{
                    Write-Error "Could not back up directory: $dir" -ErrorAction Continue
                }
            }
        }
    }

    end {
    }
}