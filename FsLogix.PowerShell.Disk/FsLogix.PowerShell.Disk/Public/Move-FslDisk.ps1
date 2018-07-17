function move-FslDisk {
    <#
        .SYNOPSIS
        Moves a vhd to another location.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER Path
        Location for either all VHD's or a specific VHD

        .PARAMETER Destination
        Where the user want's the VHD's migrated to

        .PARAMETER Ovewrite
        If the destination path already contains the same VHD,
        user can determine to overwrite.

        .EXAMPLE
        move-fslvhd -path C:\Users\danie\ODFC\test1.vhdx -Destination C:\Users\danie\FSLOGIX\test1.vhdx
        Migrates test1.vhdx in ODFC, to FSLOGIX.

        .EXAMPLE
        move-fslvhd -path C:\Users\danie\ODFC -Destination C:\Users\danie\FSLOGIX
        Migrates all the VHD's in ODFC to FSLOGIX.

        .EXAMPLE
        move-fslvhd -path C:\Users\danie\ODFC -Destination C:\Users\danie\FSLOGIX -overwrite Yes
        Migrates all the VHD's in ODFC to FSLOGIX and overwrites if the VHD already exists.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [System.String]$path,

        [Parameter(Position = 1, Mandatory = $true)]
        [System.String]$Destination,

        [Parameter(Position = 2)]
        [Switch]$Overwrite
    )

    begin {
        set-strictmode -Version latest

        if (-not(test-path -path $path)) {
            write-error "Path: $path is invalid." -ErrorAction Stop
        }

        if (-not(test-path -path $Destination)) {
            write-error "Destination: $Destination is invalid." -ErrorAction Stop
        }
    }

    process {

        $VhdDetails = get-fslvhd -path $path


        foreach ($currVhd in $VhdDetails) {

            $name = split-path -Path $currVhd.path -leaf
            $CheckIfAlreadyExists = Get-childitem -path $Destination | Where-Object {$_.Name -eq $name}

            if ($currVhd.attached) {
                Write-Error "VHD: $name is currently in use." -ErrorAction continue ## Continue to move other disks, but skip the one's we can't
            }
            else {
                if ($CheckIfAlreadyExists) {
                    if ($Overwrite) {
                        move-item -path $currVhd.path -Destination $Destination -Force
                        Write-Verbose "$(Get-Date): Overwrited and moved $name to $Destination"
                    }
                    else {
                        Write-Error "$name already exists at $Destination" -ErrorAction Continue ## Continue to move other disks, but skip the one's we can't
                    }
                }
                else {
                    try {
                        move-item -path $currVhd.path -Destination $Destination -Force
                        Write-Verbose "$(Get-Date): Moved $name to $Destination"
                    }
                    catch {
                        Write-Error $error[0]
                        continue
                    }
                }#else checkifalreadyexists
            }#else attached
        }#foreach
    }#process

    end {
    }
}