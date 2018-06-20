<#
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
function convertTo-VHDx {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [System.String]$Path,

        [Parameter(Position = 1, Mandatory = $false)]
        [System.string]$ParentPath,

        [Parameter(Position = 2, Mandatory = $false)]
        [System.string]$VhdType,

        [Parameter(Position = 3, Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("True", "False")]
        [Alias("confirm")]
        [System.string]$Remove_Old = "False"
    )
    
    begin {
        set-strictmode -Version latest
        $testforVHD = get-childitem -path $Path

        $ParentPathFound = $false
        $VHDTypeFound = $false

        $Confirm_Delete = $false
        if ($Remove_Old -eq "true") {
            $Confirm_Delete = $true
        }
    }
    
    process {

        if ($ParentPath -ne "") {
            $ParentPathFound = $true
        }

        if ($VhdType -ne "") {
            $VHDTypeFound = $true
        }

        if ($testforVHD.Extension -eq ".vhdx") {
            Write-Warning "Already a .vhdx. Exiting script..."
            exit
        }

        if ($testforVHD.Extension -eq ".vhd") {
            Write-Verbose "Obtaining single VHD $testforVHD"
            $VHDs = Get-FslDisk -path $path
        }else {
            Write-Error "File path must include .vhd extension"
            exit
        }

        if ($null -eq $VHDs) {
            Write-Warning "Could not find any VHDs."
            exit
        }

        Write-Verbose "Obtained VHD(s)."
        Write-Verbose "Converting VHD(s) to .vhdx"

        foreach ($vhd in $VHDs) {

            $name = split-path -path $vhd.path -leaf
            $VHDx = $vhd.path + "x"

            if($vhd.attached -eq $true){
                write-error "VHD $name is currently in use. Cannot convert."
            }
            
            try {
                Convert-VHD -path $vhd.path -DestinationPath $VHDx
                Write-Verbose "$name succesfully converted to a .vhdx"
            }
            catch {
                write-error $Error[0]
                exit
            }

            if ($Confirm_Delete) {
                try {
                    remove-item -Path $vhd.path -Force
                    Write-Verbose "Removed old VHD."
                }
                catch {
                    Write-Error $Error[0]
                    exit
                }
            }#if confirm_delete
        }#foreach
    }#process
    
    end {
        Write-Verbose "Completed script.."
    }
}