function move-FslDisk {
    <#
        .SYNOPSIS
        Migrates a vhd to another location.

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

        [Parameter(Position = 2, Mandatory = $false)]
        [Validateset("Yes", "No")]
        [System.String]$Overwrite = "No"
    )
    
    begin {
        set-strictmode -Version latest
        
        if (-not(test-path -path $path)) {
            write-error "Path: $path is invalid."
            exit
        }

        if (-not(test-path -path $Destination)) {
            write-error "Destination: $Destination is invalid."
            exit
        }
    }
    
    process {

        $VhdDetails = get-fslvhd -path $path
        

        foreach ($currVhd in $VhdDetails) {

            $name = split-path -Path $currVhd.path -leaf
            $CheckIfAlreadyExists = Get-childitem -path $Destination | Where-Object {$_.Name -eq $name}

            if ($currVhd.attached -eq $true) {
                Write-Error "VHD: $name is currently in use."
            }else { 
                if ($CheckIfAlreadyExists) {
                    switch ($Overwrite) {
                        "yes" {
                            move-item -path $currVhd.path -Destination $Destination -Force
                            Write-Verbose "Overwrited and migrated $name to $Destination"
                            remove-item -path $currVhd.path -force -Erroraction SilentlyContinue
                        }
                        "No" {
                            Write-Verbose "Will not overwrite. Canceled migration for $name."
                        }
                    }
                }else {
                    try {
                        move-item -path $currVhd.path -Destination $Destination -Force
                        Write-Verbose "Migrated $name to $Destination"
                    }
                    catch {
                        Write-Error $error[0]
                        exit
                    }
                }
            }#else
        }#foreach
    }#process
    
    end {
    }
}