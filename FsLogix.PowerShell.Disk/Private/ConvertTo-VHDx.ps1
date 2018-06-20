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
        [System.string]$Remove_Old = "False",

        [Parameter(Position = 4, Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("True", "False")]
        [Alias("overwrite")]
        [System.string]$Remove_Existing = "False"
    )
    
    begin {
        set-strictmode -Version latest
        $testforVHD = get-childitem -path $Path

        $ParentPathFound = $false
        $VHDTypeFound = $false

        $Confirm_Delete = $false
        $Confirm_Overwrite = $false
    }
    
    process {

        if ($ParentPath -ne "") {
            $ParentPathFound = $true
        }

        if ($VhdType -ne "") {
            $VHDTypeFound = $true
        }

        if ($Remove_Old -eq "true") {
            $Confirm_Delete = $true
        }

        if($Remove_Existing -eq "true"){
            $Confirm_Overwrite = $true
        }


        if(-not(test-path -path $Path)){
            write-error "Path: $Path could not be found"
            exit
        }
        
        if ($testforVHD.Extension -eq ".vhdx") {
            Write-Warning "Already a .vhdx. Exiting script..."
            exit
        }

        if($Path -notlike "*.vhd"){
            Write-Error "Path must include .vhd extension"
            exit
        }


        if ($testforVHD.Extension -eq ".vhd") {
            Write-Verbose "Obtaining single VHD $testforVHD"
            $VHD = Get-FslDisk -path $path
        }else {
            Write-Error "File path must include .vhd extension"
            exit
        }

        if ($null -eq $VHD) {
            Write-Warning "Could not find any VHDs."
            exit
        }

        Write-Verbose "Obtained VHD(s)."
        Write-Verbose "Converting VHD(s) to .vhdx"

        $name = split-path -path $VHD.Path -leaf
        $Old_Path = $VHD.path
        $New_Path = $Old_path + "x"

        $AlreadyExists = get-childitem -path $New_Path -ErrorAction SilentlyContinue
        if($null -ne $AlreadyExists){
            if($Confirm_Overwrite){
                Write-Warning "$New_Path already exists. User confirmed Overwrite."
                try{
                    remove-item -Path $New_Path -Force 
                }catch{
                    Write-Error $Error[0]
                }
            }else{
                Write-Warning "VHD: $New_Path already exists here."
                Write-Warning "User denied overwrite. Exiting script..."
                exit
            }
        }

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