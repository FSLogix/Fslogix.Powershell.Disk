function Test-FslProfile {
    [CmdletBinding()]
    param (

        [Parameter( Position = 0,
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true
        )][System.String]$VhdFolder,

        [Parameter( Position = 1,
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true
        )][System.String]$strSid,

        [Parameter( Position = 2,
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true
        )][System.String]$strUserName,

        [Parameter( Position = 3,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true
        )][regex]$SID_Regex = "S-\d-\d+-(\d+-){1,14}\d+$",

        [Parameter( Position = 4)]
        [Switch]$vhd,

        [Parameter( Position = 4)]
        [Switch]$vhdx
    )

    begin {
        set-strictmode -Version latest
        $opt = (Get-Host).PrivateData
        $opt.WarningForegroundColor = "Red"
    }

    process {

        #Kim_S-0-2-26-1944519217-1788772061-1800150966-14812.VHD
        if(-not(test-path -path $vhdfolder)){
            Write-Warning "Could not validate path: $vhdfolder" 
        }else{Write-Verbose "$(get-date): Validated disk location."}

        $Directory_Check = Get-Item $Vhdfolder
        if($Directory_Check -is [System.IO.DirectoryInfo]){
            $Directory = $Directory_Check.FullName
        }else{ Write-Warning "MAJOR:    Vhd location must be a directory."}

        if(!($strSid -match $SID_Regex)){
            Write-Warning "MAJOR:   SID: $strsid does not match regex."
        }else{ Write-Verbose "$(get-date): User's SID validated." }

        $FslDirectory = $Directory + "\" + $strSid + "_" + $strUserName
        if(-not(test-path $FslDirectory)){
            Write-Verbose "$(get-date): Could not find Directory for: $FslDirectory."
            Write-Verbose "$(get-date): Attempting flip-flop."
            $FslDirectory = $Directory + "\" + $strUserName + "_" + $strSid
        }
        if(-not(test-path $FslDirectory)){
            Write-Warning "MAJOR:   Could not find Directory for: $FslDirectory"
        }else {Write-Verbose "$(get-date): Directory found and validated."}

        if($vhd){
            $FSlProfile = "profile.vhd"
        }
        if($vhdx){
            $FSlProfile = "profile.vhdx"
        }
        if((-not $vhd) -and (-not $vhdx)){
            $FSlProfile = "profile.vhd"
        }

        $FslFileName = $FslDirectory + "\" + $FSlProfile
        $Fsl_Directory_name = split-path -Path $FslDirectory -leaf
        if(-not(test-path $FslFileName)){
            Write-Warning "MINOR:   $Fsl_Directory_name does not contain a $FslProfile"
        }else{
            Write-Verbose "$(get-date): Found $FslProfile."
        }
        write-output (test-path $FslFileName)
    }

    end {
        $opt.WarningForegroundColor = "Yellow"
    }
}