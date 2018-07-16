<#
Daniel, answers below.

Ulitmately I want to be able to take a path based on updating the scripts.

So for example

OST’s reside in \\server\share\usersost\%username%
Appdata is in \\server\share\users\profiles
Enumeration for migration will be an AD group called something like FSLogix.ODFC.Migrate
Vhd’s will be placed in \\server\share\ODFC
I would also like to add an option that makes the Copied files Read Denied after the copy is completed.

Script on hold since I have no ability to test active directory functionalites or use active directory cmdlets.

#>
function Move-FslOst {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.String]$DiskDestination,

        [Parameter(Position = 1, Mandatory = $true)]
        [System.String]$AdGroup,

        [Parameter(Position = 2)]
        [System.String]$Ost,

        [Parameter(Position = 3)]
        [System.String]$AppData,

        [Parameter(Position = 4)]
        [ValidateSet("VHD","VHDX")]
        [System.String]$VHDtype = "VHD",

        [Parameter(Position = 5, Mandatory = $true)]
        [Alias("Size")]
        [System.int64]$SizeInGB
    )

    begin {
        set-strictmode -Version latest
    }

    process {

        if (![System.String]::IsNullOrEmpty($ost)) {
            if ($ost -notcontains '%username%') {
                Write-Error "OST Path: $ost must end with %username%." -ErrorAction stop
            }
        }

        if($VHDtype -eq 'VHD'){
            [System.String]$VHDExtension = '.vhd'
        }else{
            [System.String]$VHDExtension = '.vhdx'
        }

        ## Assumption is after enumerating ad users, we will obtain the corresponding user's ##
        ## OST within %username% and the corresponding user's appdata within 'profiles'      ##
        if ([System.string]::IsNullOrEmpty($ost)) {
            $ost = '\\server\share\usersost\%username%'
        }

        if ([System.string]::IsNullOrEmpty($AppData)) {
            $appdata = '\\server\share\users\profiles'
        }

        if ([System.string]::IsNullOrEmpty($DiskDestination)) {
            $DiskDestination = '\\server\share\ODFC'
        }

        if(-not(test-path $AppData)){
            Write-Error "Could not find AppData Directory: $appdata" -ErrorAction Stop
        }
        if (-not(test-path -path $DiskDestination)) {
            Write-Error "Could not find migrated disk path: $diskdestination" -ErrorAction Stop
        }

        $AppDataProfiles = get-childitem -path $AppData

        ## Enumerate Ad Group and obtain user information ##
        ## What are these values?                         ##
        get-adgroupmember $AdGroup -Recursive | ForEach-Object {
            $userData = get-aduser $_

            $FSLFullUser = $userData.Name
            $FSLUser = $userData.SamAccountName
            $strSid = $userData.SID

            write-verbose "$FslFullUser -|- $FSLUser -|- $strSId"

            ## Obtain user's information                              ##
            ## How are user's app data folder's generally named?      ##
            ## How are ost folder's named?                            ##
            ## Generic method to find the directories. Possibly wrong ##
            $ost = $ost.Replace('%username%', $FSlUser)
            $Users_AppData = $AppDataProfiles | Where-Object {$_.Name -like "*$strSid*"}
            [System.String]$Users_AppDataDir = [System.String]$Users_AppData.FullName
            [System.String]$Users_Migrated_VHD_Name = [System.String]$Users_AppData.Name + [System.String]$VHDExtension

            ## Validate that the paths exist and are valid ##
            if (-not(test-path -path $ost)) {
                Write-Error "Could not retrieve OST's from path: $ost" -ErrorAction Stop
            }else{ Write-Verbose "$FSLUser's OST is set."}

            if (-not(test-path -path $Users_AppDataDir)) {
                Write-Error "Could not retrieve AppData from path: $Users_AppDataDir" -ErrorAction Stop
            }else{ Write-Verbose "$FSLUser's AppData is set"}

            ## Create new Migrated VHD ##
            [System.String]$Migrated_VHD = [System.String]$DiskDestination + "\" + [System.String]$Users_Migrated_VHD_Name
            New-FslDisk -NewVHDPath $Migrated_VHD -SizeInGB $SizeInGB -overwrite

            if (-not(test-path -path $Migrated_VHD)){
                Write-Error "Could not $Migrated_VHD" -ErrorAction Stop
            }else{Write-Verbose "$FSLUser's Migrated VHD set."}

            ## Copy Appdata contents over ##
            copy-FslToDisk -VhdPath $Migrated_VHD -FilePath $Users_AppDataDir -Overwrite
            copy-FslToDisk -VhdPath $Migrated_VHD -FilePath $ost -Overwrite


        }#admember enumeration
    }#process

    end {
    }
}