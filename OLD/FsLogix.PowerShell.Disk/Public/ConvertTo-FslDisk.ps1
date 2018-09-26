#Requires -Modules "Hyper-V"
function ConvertTo-FslDisk {
    <#
        .SYNOPSIS
        Converts virtual hard disks into .vhd or .vhdx extensions.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

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
        ConvertTo-fsldisk -path "C:\Users\danie\Documents\ODFC" -type "vhd" -removeold
        Will search for all the .vhdx in the folder ODFC and convert them into a vhd. The old
        .vhdx will then be deleted.

        .EXAMPLE
        ConvertTo-fsldisk -path "C:\Users\danie\Documents\ODFC\test1.vhd" -type "vhdx" -removeold -overwrite
        Will convert test1.vhd into a vhdx. The script will then remove the old test1.vhd and overwrite any existing test1.vhdx.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$Path,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("vhd", "vhdx")]
        [System.String]$ConvertTo,

        [Parameter(Position = 2,ValueFromPipelineByPropertyName = $true)]
        [Alias("RemoveOld")]
        [Switch]$Remove_Old,

        [Parameter(Position = 3,ValueFromPipelineByPropertyName = $true)]
        [Alias("overwrite")]
        [Switch]$Remove_Existing

    )

    begin {
        set-strictmode -Version latest
    }

    process {

        $Convert_To_VHD = $false

        if ($ConvertTo -eq "vhd") {
            $Convert_To_VHD = $true
        }

        if ($ConvertTo -eq "vhdx") {
            $Convert_To_VHD = $false
        }

        ## Get VHD(s) within Path ##
        $VHDs = get-childitem -Path $Path -filter "*.vhd*"
        if ($null -eq $VHDs) {
            Write-Error "Could not find any VHD's in $path" -ErrorAction Stop
        }

        if ($Convert_To_VHD) {
            $VhdDetails = $VHDs.FullName | get-fsldisk | Where-Object {$_.vhdformat -eq "vhdx"}
        }else {
            $VhdDetails = $VHDs.FullName | get-fsldisk | Where-Object {$_.vhdformat -eq "vhd"}
        }
        if ($null -eq $VhdDetails) {
            Write-Warning "VHD's in $path are already $ConvertTo type, cannot convert."
        }

        ## Convert to VHD                      ##
        ## Helper functions will handle errors ##
        foreach ($vhd in $VhdDetails) {

            [System.String]$command = ""

            ## ConvertTo-VHD & ConvertTo-VHDx are FsLogix's helper function ##
            if($Convert_To_VHD){
                $command += "convertTo-VHD"
            }else{
                $command += "convertTo-VHDx"
            }

            $path = $vhd.path
            $command += " -path $path"

            if($Remove_Old){
                $command += " -removeold"
            }

            if($Remove_Existing){
                $command += " -overwrite"
            }

            Invoke-Expression $command

        }
    }
    end {
    }
}