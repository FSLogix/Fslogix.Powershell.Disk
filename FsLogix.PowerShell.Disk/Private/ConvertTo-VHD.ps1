<#
    .EXAMPLE
    convertTo-FslVHD -path C:\Users\test.vhdx
    Will convert the single vhdx, test.vhdx, into a vhd.

    .EXAMPLE
    converTo-FslVHD -path C:\Users\ODFC\test1.vhdx -confirm true
    Will convert test1.vhdx to a .vhd and remove the old .vhdx.
#>
function convertTo-VHD {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [System.String]$Path,

        [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("True", "False")]
        [Alias("confirm")]
        [System.string]$Remove_Old = "False"
    )
    
    begin {
        set-strictmode -Version latest

        $testforVHD = get-childitem -path $Path

        $Confirm_Delete = $false
        if ($Remove_Old -eq "true") {
            $Confirm_Delete = $true
        }

        
    }
    
    process {

        if($Path -notlike "*.vhdx"){
            Write-Error "Path must include .vhdx extension"
            exit
        }
    
        if ($testforVHD.Extension -eq ".vhd") {
            Write-Warning "Already a .vhd. Exiting script..."
            exit
        }

        if ($testforVHD.Extension -eq ".vhdx") {
            Write-Verbose "Obtaining VHD from $path"
            $VHD = get-fsldisk -path $path
        }else{
            write-error "File path must include .vhdx extension"
            exit
        }

        if ($null -eq $VHD) {
            Write-Warning "Could not find any VHDs."
            exit
        }

        Write-Verbose "Obtained VHD."
        Write-Verbose "Converting VHD to .vhd"
    
        $name = split-path -path $VHD.Path -leaf
        $Old_Path = $VHD.path
        $New_Path = $Old_path.substring(0,$Old_Path.length-1)

        if($VHD.attached -eq $true){
            Write-Warning "VHD $name is currently in use. Cannot convert."
            exit
        }

        try {
            Convert-VHD -path $Old_Path -DestinationPath $New_Path
            Write-Verbose "$name succesfully converted to a .vhd"
        }
        catch {
            write-error $Error[0]
            exit
        }

        if ($Confirm_Delete) {
            try {
                Write-Verbose "User confirmed deletion of old VHD"
                remove-item -Path $Old_Path -Force 
                Write-Verbose "Removed old VHD."
            }
            catch {
                Write-Error $Error[0]
                exit
            }
        }
    }#process
    
    end {
        Write-Verbose "Completed script.."
    }
}