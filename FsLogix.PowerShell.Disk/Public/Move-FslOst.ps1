#Requires -Modules "Hyper-V"
#Requires -Modules "ActiveDirectory"
<#
    Daniel, answers below.

    Ulitmately I want to be able to take a path based on updating the scripts.

    So for example

    OST’s reside in \\server\share\usersost\%username%
    Appdata is in \\server\share\users\profiles
    Enumeration for migration will be an AD group called something like FSLogix.ODFC.Migrate
    Vhd’s will be placed in \\server\share\ODFC
    I would also like to add an option that makes the Copied files Read Denied after the copy is completed.
#>
function Move-FslOst {
    <#
        .SYNOPSIS
        Migrates an ad-user to a VHD with it's corresponding .OST and AppData.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        https://github.com/FSLogix

        .PARAMETER DiskDestination
        The directory where the user wants the migrated VHD to be located.

        .PARAMETER AdGroup
        Active Directory group name

        .PARAMETER OST
        Ost directory location, user should use %username% at the end.
        User profile will replace the %username%.
        If OST is not specified, defaulted to: \\server\share\usersost\%username%

        .PARAMETER APPDATA
        AppData directory location. If AppData is not specified,
        directory defaulted to: \\server\share\users\profiles

        .PARAMETER VHDFormat
        User's option whether the migrated VHD is a vhd or vhdx.
        Defaulted to vhd.

        .PARAMETER VHDType
        User's option whether the migrated VHD is dynamic or fixed.
        Defaulted to dynamic.

        .PARAMETER SizeInGB
        User's input for the migrated disk's size in gigabytes.

        .EXAMPLE
        Move-FslOst -diskdestination 'C:\Users\Daniel\ODFC' -AdGroup 'FsLogix'
        Will migrate all the active directory user's in AdGroup FsLogix to C:\Users\Daniel\ODFC.

    #>
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
        [ValidateSet("VHD", "VHDX")]
        [System.String]$VHDformat = "VHD", #Defaulted to .vhd

        [Parameter(Position = 5)]
        [ValidateSet("Dynamic", "Fixed")]
        [System.String]$VHDtype = "Dynamic", #Defaulted to dynamic

        [Parameter(Position = 6, Mandatory = $true)]
        [Alias("Size")]
        [System.int64]$SizeInGB
    )

    begin {
        set-strictmode -Version latest
    }

    process {

        if ($VHDformat -eq 'VHD') {
            [System.String]$VHDExtension = '.vhd'
        }
        else {
            [System.String]$VHDExtension = '.vhdx'
        }

        ## Assumption is after enumerating ad users, we will obtain the corresponding user's ##
        ## OST within %username% and the corresponding user's appdata within 'profiles'      ##
        ## Will need to validate with David Young on exactly what he requires                ##
        if (!$ost) {
            $ost = '\\server\share\usersost\%username%'
            Write-Verbose "$(get-date): User did not enter OST path: Defaulting to $ost."
        }

        if (!$AppData) {
            $appdata = '\\server\share\users\profiles'
            Write-Verbose "$(get-date): User did not enter AppData profile directory. Defaulting to $appdata."
        }

        if (!$DiskDestination) {
            $DiskDestination = '\\server\share\ODFC'
            Write-Verbose "$(get-date): User did not enter Destination director. Defaulted to $diskdestination."
        }

        if (-not(test-path $AppData)) {
            Write-Error "Could not find AppData Directory: $appdata" -ErrorAction Stop
        }
        if (-not(test-path -path $DiskDestination)) {
            Write-Error "Could not find migrated disk path: $diskdestination" -ErrorAction Stop
        }

        $Test_AppData_Dir = get-item $AppData
        if(!$Test_AppData_Dir.PSIsContainer){
            Write-Error "AppData path must be a directory/folder." -ErrorAction Stop
        }

        $AppDataProfiles = get-childitem -path $AppData

        ## Enumerate Ad Group and obtain user information ##
        ## How are these values outputted?                ##
        get-adgroupmember $AdGroup -Recursive -ErrorAction Stop | ForEach-Object {

            [System.String]$FSLFullUser = $_.Name
            [System.String]$FSLUser = $_.SamAccountName
            [System.String]$strSid = $_.SID

            Write-Verbose "$(Get-Date): Beginning OST migration for $FSLUser."
            Write-Verbose "$(Get-Date): FslFullUser: $FSLFullUser"
            write-verbose "$(Get-Date): FslUser: $FSLUser."
            Write-Verbose "$(Get-Date): FslSID: $strSid."

            $Users_AppData = ($AppDataProfiles).where({$_.Name -like "*$strSid*"})
            if ($null -eq $Users_AppData) {
                Write-Error "Could not retrieve App Data profiles in $appdataprofiles" -ErrorAction Stop
            }
            [System.String]$Users_AppDataDir = [System.String]$Users_AppData.FullName
            #[System.String]$Users_Migrated_VHD_Name = $FSLUser + "_" + $strSid + $VHDExtension
            [System.String]$Users_Migrated_VHD_Name = $Users_AppData.Name + $VHDExtension

            ## Get the ost path ##
            if ((split-path -path $ost -leaf) -ne '%username%') {
                $ost = $ost + "\" + [System.String]$FSLUser
            }
            else {
                $ost = $ost.Replace('%username%', $FSlUser)
            }

            ## Validate that the paths exist and are valid ##
            if (-not(test-path -path $ost)) {
                Write-Error "Could not retrieve OST's from path: $ost" -ErrorAction Stop
            }
            else { Write-Verbose "$(Get-Date): $FslUser's OST is set."}

            $Users_Ost = Get-childitem -path $ost -Filter "*.ost" -Recurse

            if (-not(test-path -path $Users_AppDataDir)) {
                Write-Error "Could not retrieve AppData from path: $Users_AppDataDir" -ErrorAction Stop
            }
            else { Write-Verbose "$(Get-Date): $FslUser's AppData is set."}

            ## Create new Migrated VHD ##
            [System.String]$Migrated_VHD = [System.String]$DiskDestination
            New-FslDisk -NewVHDPath $Migrated_VHD -name $Users_Migrated_VHD_Name -SizeInGB $SizeInGB -Type $VHDtype -overwrite
            $New_Migrated_VHD = $Migrated_VHD + "\" + $Users_Migrated_VHD_Name

            if (-not(test-path -path $New_Migrated_VHD)) {
                Write-Error "Could not find: $New_Migrated_VHD" -ErrorAction Stop
            }
            else {Write-Verbose "$(Get-Date): $FslUser's migrated disk is set."}

            ## Copy Appdata contents over ##
            if ($null -eq $Users_AppData) {
                Write-Warning "Could not find $FslUser's AppData profile."
                continue
            }
            else {
                $AppDataDest = split-path $Users_AppDataDir -Leaf
                Write-Verbose "$(Get-Date): Found $FslUser's AppData files."
                Write-Verbose "$(Get-Date): Copying AppData to $New_Migrated_VHD\$appDataDest"
                copy-FslToDisk -VhdPath $New_Migrated_VHD -FilePath $Users_AppDataDir -Destination $AppDataDest -Overwrite -recurse
            }
            if ($null -eq $Users_Ost) {
                Write-Warning "Could not find $FslUser's Ost file."
                continue
            }
            else {
               # $OSTDest = split-path $Users_Ost.FullName -Leaf
                Write-Verbose "$(Get-Date): Found $FslUser's OST file."
                Write-Verbose "$(Get-Date): Copying OST to $New_Migrated_VHD"
                copy-FslToDisk -VhdPath $New_Migrated_VHD -FilePath $Users_Ost.FullName -Overwrite -recurse
            }
            Write-Verbose "$(Get-Date): Finished OST Migration for: $FslUser."
            $New_Migrated_VHD | dismount-fsldisk
            $ost = split-path -path $ost
        }#admember enumeration
    }#process

    end {
    }
}