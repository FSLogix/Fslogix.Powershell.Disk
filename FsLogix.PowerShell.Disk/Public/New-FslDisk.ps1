<#
    .SYNOPSIS
    Creates a new VHD of .vhd or .vhdx extension

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
    New-FslVHD -path C:\Users\Desktop\ODFC\test1.vhdx
    Creates a new VHD, test1.vhdx, in the ODFC folder with a default size 
    of 10gb and automatically formats a volume and drive letter.

    .EXAMPLE
    New-FslVHD C:\Users\Desktop\ODFC\FSLOGIX\test1.vhdx -parentpath C:\users\Desktop\ODFC\test2.vhdx
    Creates a new VHD, test1.vhdx with test2.vdhx as it's parent.

    .EXAMPLE
    new-FslVHD C:\Users\Desktop\ODFC\test1.vhdx -Size 25gb -Type Dynamic
    Creates a new dynamic VHD, test1.vhdx, of size 25gb.

    .EXAMPLE
    new-FslVHD C:\Users\Desktop\ODFC\test1.vhdx -overwrite true
    Creates a new VHD, test1.vhdx, and overwrites the old test1.vhdx
    that existed in the given path.
#>
function New-FslDisk {
    [CmdletBinding()]
    param (
        
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("path")]
        [System.string]$NewVHDPath,

        [Parameter(Position = 1, Mandatory = $false)]
        [Alias("ParentPath")]
        [System.string]$VHDParentPath,

        [Parameter(Position = 2, Mandatory = $false)]
        [Alias("Size")]
        [System.int64]$SizeInGB,

        [Parameter(Position = 3, Mandatory = $false)]
        [ValidateSet("Dynamic", "Fixed")]
        [System.String]$Type = "Dynamic",

        [Parameter(Position = 4, Mandatory = $false)]
        [ValidateSet("True", "False")]
        [Alias("Overwrite")]
        [System.String]$Confirm_Delete = "False"

    )#param
    
    begin {
        set-strictmode -Version latest

        $VerbosePreference = "continue"
        
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

        if ($Confirm_Delete -eq "True") {
            $Overwrite = $true
        }

        if ($SizeInGB -eq 0) {
            $SizeInGB = 10gb
        }
        if(($ParentPath_Found -eq $false) -and ($Fixed_Found -eq $false)){
            $Custom_VHD = $true
        }

        if((get-module).Name -notcontains "Hyper-V"){
            Write-Error "Hyper-V module must be installed."
            exit
        }

    }#Begin
    
    process {

        if ($NewVHDPath -notlike "*.vhd*") {
            Write-Error "The file extension for $NewVHDPath must include a .vhd or .vhdx extension."
            exit
        }
    
        if (test-path -path $NewVHDPath) {
            if ($Overwrite -eq $false) {
                Write-Error "VHD already exists here! User confirmed false for overwrite."
                exit
            }else {
                Write-Verbose "Overwriting old VHD..."
                try {
                    remove-item -path $NewVHDPath -ErrorAction stop -Force
                }
                catch {
                    Write-Verbose "Could not delete old VHD."
                    Write-Error $Error[0]
                    exit
                }
            }
        }#Test-path

        if ($ParentPath_Found) {
            $Fixed_Found = $false
            try {
                Write-Verbose "Initializing VHD with Parent..."
                $CreateVHD = New-VHD -path $NewVHDPath -ParentPath $VHDParentPath -SizeBytes $size -ErrorAction Stop
            }
            catch {
                Write-Verbose "Could not initialize VHD."
                Write-Error $Error[0]
            }
        }#if parentpath_found

        if ($Fixed_Found) {
            try {
                Write-Verbose "Initializing Fixed VHD..."
                $CreateVHD = New-VHD -Path $NewVHDPath -Fixed -SizeBytes $SizeInGB -ErrorAction Stop
            }
            catch {
                Write-Verbose "Could not Initialize VHD."
                Write-Error $Error[0]
                exit
            }
        }#if fixed_found
        
        if($Custom_VHD){#dynamic
            try {
                Write-Verbose "Initializing Dynamic VHD..."
                $CreateVHD = New-VHD -Path $NewVHDPath -SizeBytes $SizeInGB -Dynamic -ErrorAction stop
            }
            catch {
                Write-Verbose "Could not Initialize VHD."
                Write-Error $Error[0]
                exit
            }
        }#if Custom_VHD
        
        try {
            Write-Verbose "Creating Partition..."
            $CreatePartition = $CreateVHD | Mount-VHD -Passthru |Initialize-Disk -Passthru -ErrorAction SilentlyContinue |New-Partition -AssignDriveLetter -UseMaximumSize 
        }
        catch {
            Write-Verbose "Could not create partition"
            Write-Error $Error[0]
            exit
        }
        

        try {
            Write-Verbose "Formatting Volume..."
            $CreatePartition | Format-Volume -FileSystem NTFS -Confirm:$false -Force
        }
        catch {
            Write-Verbose "Could not format volume."
            Write-Error $Error[0]
            exit
        }

    } #process
    
    end {
        Write-Verbose "VHD succesfully created. Exiting script..."
    }
}