function ConvertTo-FslDisk {
    <#
        .SYNOPSIS
        Converts virtual hard disks into .vhd or .vhdx extensions.

        .PARAMETER path
        Path to the given VHD.

        .PARAMETER converTo
        The type of VHD the user wants to convert to. 
        User can choose between VHD or VHDx.

        .PARAMETER Remove_Old
        If user wants to remove the old VHD after conversion.

        .PARAMETER Remove_Existing
        If user wants to remove the VHD if the specified VHD already exist.

        .EXAMPLE
        ConvertTo-fsldisk -path "C:\Users\danie\documents\ODFC\test1.vhd" -type "vhdx"
        Will convert test1.vhd into a vhdx.

        .EXAMPLE
        ConvertTo-fsldisk -path "C:\Users\danie\Documents\ODFC" -type "vhdx"
        Will search for all the .vhd in folder ODFC and convert them into a vhdx.

        .EXAMPLE
        ConvertTo-fsldisk -path "C:\Users\danie\Documents\ODFC" -type "vhd" -confirm "true"
        Will search for all the .vhdx in the folder ODFC and convert them into a vhd. The old
        .vhdx will then be deleted.

        .EXAMPLE
        ConvertTo-fsldisk -path "C:\Users\danie\Documents\ODFC\test1.vhd" -type "vhdx" -confirm "true" -overwrite "true"
        Will convert test1.vhd into a vhdx. The script will then remove the old test1.vhd and overwrite any existing test1.vhdx.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$Path,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateSet("vhd", "vhdx")]
        [System.String]$ConvertTo,

        [Parameter(Position = 2, Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("True", "False")]
        [Alias("confirm")]
        [System.string]$Remove_Old = "False",

        [Parameter(Position = 3, Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("True", "False")]
        [Alias("overwrite")]
        [System.string]$Remove_Existing = "False"

    )
    
    begin {
        ## Helper function to validate requirements
        Get-Requirements
        
        $Convert_To_VHD = $false
        $Convert_To_VHDx = $false
        $Delete_Existing_VHD = $false
        $Delete_Old_VHD = $false

    }
    
    process {
        if ($ConvertTo -eq "vhd") {
            $Convert_To_VHD = $true
        }

        if ($ConvertTo -eq "vhdx") {
            $Convert_To_VHDx = $true
        }
        
        if ($Remove_Old -eq "true") {
            $Delete_Old_VHD = $true
        }

        if ($Remove_Existing -eq "true") {
            $Delete_Existing_VHD = $true
        }

        if (-not(test-path -path $Path)) {
            Write-Error "Path: $path is invalid. Exiting script..."
            exit
        }       

        ## Get VHD(s) within Path ##
        $VHDs = get-childitem -Path $Path -filter "*.vhd*"
        if ($null -eq $VHDs) {
            Write-Error "Could not find any VHD's in $path"
            exit
        }

        if ($Convert_To_VHD) {

            Write-Verbose "Obtaining VHDx(s) in $path"
            $VhdDetails = $VHDs.FullName | get-fsldisk | Where-Object {$_.vhdformat -eq "VHDX"}

        }
        else {

            write-verbose "Obtaining VHD(s) in $path"
            $VhdDetails = $VHDs.FullName | get-fsldisk | where-object {$_.vhdformat -eq "VHD"}

        }
        if ($null -eq $VhdDetails) {
            Write-Error "Already the same type, cannot convert."
            exit
        }

        Write-Verbose "Gathered all VHD(s) information."
        
        ## Convert to VHD                      ##
        ## Helper functions will handle errors ##
        Write-Verbose "Calling helper script to convert VHD's."
        foreach ($vhd in $VhdDetails) {

            if ($Convert_To_VHD) {
                convertTo-VHD -path $vhd.path -confirm $Remove_Old -overwrite $Remove_Existing
            }
            else {
                convertTo-VHDx -path $vhd.path -confirm $Remove_Old -overwrite $Remove_Existing
            }
        }
    }
    
    end {
        Write-Verbose "Finished ConvertTo-FslDisk script. Exiting..."
    }
}