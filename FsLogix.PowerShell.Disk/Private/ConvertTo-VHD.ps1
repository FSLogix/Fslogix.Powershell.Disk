function convertTo-VHD {
    <#
        .PARAMETER path
        Path to the given .vhd.

        .PARAMETER Remove_Old
        If user wants to remove the old VHD after conversion.

        .PARAMETER Remove_Existing
        If user wants to remove the VHD is the specified VHD already exist.s

        .EXAMPLE
        convertTo-VHD -path C:\Users\test.vhdx
        Will convert the single vhdx, test.vhdx, into a vhd.

        .EXAMPLE
        converTo-VHD -path C:\Users\ODFC\test1.vhdx -confirm true
        Will convert test1.vhdx to a .vhd and remove the old .vhdx.

        .EXAMPLE
        convertTo-VHD -path C:\Users\ODFC\test1.vhdx -overwrite true -confirm true
        Will Convert test1.vhdx to a .vhd. If a test1.vhd already exists in the given
        path, then it'll be overwritten. Once the conversion is completed, the script
        will remove the old test1.vhdx.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$Path,

        [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("True", "False")]
        [Alias("confirm")]
        [System.string]$Remove_Old = "False",

        [Parameter(Position = 2, Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("True", "False")]
        [Alias("overwrite")]
        [System.string]$Remove_Existing = "False"


    )
    
    begin {
        set-strictmode -Version latest

        $testforVHD = get-childitem -path $Path

        $Confirm_Delete = $false
        $Confirm_Overwrite = $false
    }
    
    process {

        if(-not(test-path -path $Path)){
            write-error "Path: $Path could not be found"
            exit
        }

        if($Path -notlike "*.vhdx"){
            Write-Error "Path must include .vhdx extension"
            exit
        }
    
        if ($testforVHD.Extension -eq ".vhd") {
            Write-Warning "$Path Already a .vhd. Exiting script..."
            exit
        }

        if ($testforVHD.Extension -eq ".vhdx") {
            Write-Verbose "Obtaining VHD from $path"
            $VHD = get-fsldisk -path $path
        }else{
            write-error "Incorrect extension. Path must include .vhdx extension."
            exit
        }

        if ($null -eq $VHD) {
            Write-Warning "Could not find any VHDs."
            exit
        }

        if ($Remove_Old -eq "true") { 
            $Confirm_Delete = $true 
        }

        if($Remove_Existing -eq "true"){
            $Confirm_Overwrite = $true
        }

        Write-Verbose "Obtained VHD."
        Write-Verbose "Converting VHD to .vhd"
    
        $name = split-path -path $VHD.Path -leaf
        $Old_Path = $VHD.path
        $New_Path = $Old_path.substring(0,$Old_Path.length-1)

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
                Write-warning "User denied overwrite. Exiting script..."
                exit
            }
        }
    
        if($VHD.attached -eq $true){
            Write-Warning "VHD $name is currently in use. Cannot convert."
            exit
        }

        try {
            Convert-VHD -path $Old_Path -DestinationPath $New_Path
        }
        catch {
            write-error $Error[0]
            exit
        }

        Write-Verbose "$name succesfully converted to a .vhd"

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