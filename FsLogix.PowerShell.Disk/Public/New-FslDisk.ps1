function New-FslDisk {
    <#
        .SYNOPSIS
        Creates a new VHD of .vhd or .vhdx extension

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER NewVHDPath
        Location for where the user wants to place the new VHD.

        .PARAMETER VHDParentPath
        Optional Parent Path for the new VHD

        .PARAMETER SizeInGB
        The Size of the new VHD. Defaulted at 10gb.

        .PARAMETER Type
        VHD Type of Dynamic or Fixed

        .PARAMETER Confirm_Delete
        User choice to confirm overwrite of VHD if one already exists in the
        given path.

        .EXAMPLE
        New-Fsldisk -path C:\Users\Desktop\ODFC\test1.vhdx
        Creates a new VHD, test1.vhdx, in the ODFC folder with a default size
        of 10gb and automatically formats a volume and drive letter.

        .EXAMPLE
        New-Fsldisk C:\Users\Desktop\ODFC\FSLOGIX\test1.vhdx -parentpath C:\users\Desktop\ODFC\test2.vhdx
        Creates a new VHD, test1.vhdx with test2.vdhx as it's parent.

        .EXAMPLE
        new-Fsldisk C:\Users\Desktop\ODFC\test1.vhdx -Size 25gb -Type Dynamic
        Creates a new dynamic VHD, test1.vhdx, of size 25gb.

        .EXAMPLE
        new-Fsldisk C:\Users\Desktop\ODFC\test1.vhdx -overwrite true
        Creates a new VHD, test1.vhdx, and overwrites the old test1.vhdx
        that existed in the given path.
    #>
    [CmdletBinding()]
    param (

        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("path")]
        [System.string]$NewVHDPath,

        [Parameter(Position = 1)]
        [Alias("ParentPath")]
        [System.string]$VHDParentPath,

        [Parameter(Position = 2)]
        [Alias("Size")]
        [System.int64]$SizeInGB,

        [Parameter(Position = 3)]
        [ValidateSet("Dynamic", "Fixed")]
        [System.String]$Type = "Dynamic",

        [Parameter(Position = 4)]
        [Alias("Overwrite")]
        [switch]$Confirm_Delete,

        [Parameter(Position = 5,ValuefromPipelineByPropertyName = $true, ValuefromPipeline = $true)]
        [regex]$OriginalMatch = "^(.*?)_S-\d-\d+-(\d+-){1,14}\d+$"

    )#param

    begin {
        Set-strictmode -Version latest

        $Custom_VHD = $false
        $ParentPath_Found = $false
        $Fixed_Found = $false
        $Overwrite = $false

        if ($VHDParentPath -ne "") {
            $ParentPath_Found = $true
        }

        if ($Type -eq "Fixed") {
            $Fixed_Found = $true
        }

        if ($Confirm_Delete) {
            $Overwrite = $true
        }

        if ($SizeInGB -eq 0) {
            $SizeInGB = 10gb
        }
        if(($ParentPath_Found -eq $false) -and ($Fixed_Found -eq $false)){
            $Custom_VHD = $true
        }

    }#Begin

    process {

        if ($NewVHDPath -notlike "*.vhd*") {
            Write-Error "The file extension for $NewVHDPath must include a .vhd or .vhdx extension."
            exit
        } else {
            $VHD_Name = split-path -path $NewVHDPath -Leaf
        }

        if (test-path -path $NewVHDPath) {
            if ($Overwrite -eq $false) {
                Write-Error "VHD already exists here! User confirmed false for overwrite."
                exit
            }else {
                Write-Verbose "$(Get-Date): Overwriting old VHD..."
                try {
                    remove-item -path $NewVHDPath -ErrorAction stop -Force
                }
                catch {
                    Write-Verbose "$(Get-Date): Could not delete old VHD."
                    Write-Error $Error[0]
                    exit
                }
            }
        }#Test-path

        $index = $vhd1.IndexOf('.vhd')
        if ($VHD_Name.substring(0,$index) -match $OriginalMatch){
            Write-Verbose "$(Get-Date): Validated VHD's name: $VHD_Name"
        }else{
            Write-Warning "VHD: $VHD_Name does not match regex."
        }


        if ($ParentPath_Found) {
            $Fixed_Found = $false
            try {
                Write-Verbose "$(Get-Date): Initializing VHD with Parent..."
                $CreateVHD = New-VHD -path $NewVHDPath -ParentPath $VHDParentPath -SizeBytes $size -ErrorAction Stop
            }
            catch {
                Write-Verbose "$(Get-Date): Could not initialize VHD."
                Write-Error $Error[0]
            }
        }#if parentpath_found

        if ($Fixed_Found) {
            try {
                Write-Verbose "$(Get-Date): Initializing Fixed VHD..."
                $CreateVHD = New-VHD -Path $NewVHDPath -Fixed -SizeBytes $SizeInGB -ErrorAction Stop
            }
            catch {
                Write-Verbose "$(Get-Date): Could not Initialize VHD."
                Write-Error $Error[0]
                exit
            }
        }#if fixed_found

        if($Custom_VHD){#dynamic
            try {
                Write-Verbose "$(Get-Date): Initializing Dynamic VHD..."
                $CreateVHD = New-VHD -Path $NewVHDPath -SizeBytes $SizeInGB -Dynamic -ErrorAction stop
            }
            catch {
                Write-Verbose "$(Get-Date): Could not Initialize VHD."
                Write-Error $Error[0]
                exit
            }
        }#if Custom_VHD

        try {
            Write-Verbose "$(Get-Date): Creating Partition..."
            $CreatePartition = $CreateVHD | Mount-VHD -Passthru |Initialize-Disk -Passthru -ErrorAction SilentlyContinue |New-Partition -AssignDriveLetter -UseMaximumSize
        }
        catch {
            Write-Verbose "$(Get-Date): Could not create partition"
            Write-Error $Error[0]
            exit
        }


        try {
            Write-Verbose "$(Get-Date): Formatting Volume..."
            $CreatePartition | Format-Volume -FileSystem NTFS -Confirm:$false -Force
        }
        catch {
            Write-Verbose "$(Get-Date): Could not format volume."
            Write-Error $Error[0]
            exit
        }

        try{
            Write-Verbose "$(Get-Date): Validating VHD..."
            if(test-fslvhd -path $NewVHDPath){
                Write-Verbose "$(Get-Date): VHD succesfully created. Exiting script..."
            }else{
                Write-Warning "$(Get-Date): VHD was created but unable to be used."
            }
        }catch{
            Write-Error $Error[0]
        }

    } #process

    end {

    }
}