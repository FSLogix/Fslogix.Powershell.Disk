#Requires -Modules "Hyper-V"
function convertTo-VHDx {
    <#
        .SYNOPSIS
        Converts a Virtual hard disk into a vhdx

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .EXAMPLE
        convertTo-FslVHDx -path C:\Users\test.vhd
        Will convert the single vhd, test.vhd, into a vhdx.

        .EXAMPLE
        convertTo-FslVHDx -path C:\Users\ODFC\
        Will convert all the VHD's within this path to a vhdx.

        .EXAMPLE
        converTo-FslVHDx -path C:\Users\ODFC\test1.vhd -removeold true
        Will convert test1.vhd to a .vhdx and remove the old .vhd.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$Path,

        [Parameter(Position = 3, ValueFromPipelineByPropertyName = $true)]
        [Alias("RemoveOld")]
        [Switch]$Remove_Old,

        [Parameter(Position = 4, ValueFromPipelineByPropertyName = $true)]
        [Alias("overwrite")]
        [Switch]$Remove_Existing
    )

    begin {
        set-strictmode -Version latest

        $Confirm_Delete = $false
        $Confirm_Overwrite = $false
    }

    process {

        if ($Remove_Old) {
            $Confirm_Delete = $true
        }

        if ($Remove_Existing) {
            $Confirm_Overwrite = $true
        }


        if (-not(test-path -path $Path)) {
            write-error "Path: $Path could not be found" -ErrorAction Stop
        }

        if ($Path -notlike "*.vhd") {
            Write-Error "Path must include .vhd extension" -ErrorAction Stop
        }

        $VHD = Get-FslDisk -path $path

        $name = split-path -path $VHD.Path -leaf
        $Old_Path = $VHD.path
        $New_Path = $Old_path + "x"

        if (test-path -path $New_Path) {
            if ($Confirm_Overwrite) {
                try {
                    remove-item -Path $New_Path -Force
                }
                catch {
                    Write-Error $Error[0]
                }
            }
            else {
                Write-Warning "VHD: $New_Path already exists here."
                exit
            }
        }

        if ($VHD.attached) {
            Write-Warning "VHD $name is currently in use. Cannot convert."
            exit
        }

        try {
            Convert-VHD -path $Old_Path -DestinationPath $New_Path
            Write-Verbose "$(Get-Date): $name succesfully converted to a .vhdx"
        }
        catch {
            write-error $Error[0]
            exit
        }

        if ($Confirm_Delete) {
            try {
                remove-item -Path $Old_Path -Force
                Write-Verbose "$(Get-Date): Removed old VHD."
            }
            catch {
                Write-Error $Error[0]
                exit
            }
        }
    }#process

    end {
    }
}