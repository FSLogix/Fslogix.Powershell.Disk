#Requires -Modules "Hyper-V"
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
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$Path,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [Alias("RemoveOld")]
        [Switch]$Remove_Old,

        [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)]
        [Alias("overwrite")]
        [Switch]$Remove_Existing


    )

    begin {
        set-strictmode -Version latest
        $Confirm_Delete = $false
        $Confirm_Overwrite = $false
    }

    process {

        if(-not(test-path -path $Path)){
            write-error "Path: $Path could not be found" -ErrorAction Stop
        }

        if($Path -notlike "*.vhdx"){
            Write-Error "Path must include .vhdx extension" -ErrorAction Stop
        }

        $VHD = Get-FslDisk -path $Path

        if ($Remove_Old) {
            $Confirm_Delete = $true
        }

        if($Remove_Existing){
            $Confirm_Overwrite = $true
        }

        $name = split-path -path $VHD.Path -leaf
        $Old_Path = $VHD.path
        $New_Path = $Old_path.substring(0,$Old_Path.length-1)

        if(test-path -path $New_Path){
            if($Confirm_Overwrite){
                try{
                    remove-item -Path $New_Path -Force
                }catch{
                    Write-Error $Error[0]
                }
            }else{
                Write-Warning "VHD: $New_Path already exists here."
                break
            }
        }

        if($VHD.attached){
            Write-Warning "VHD $name is currently in use. Cannot convert."
        }

        try {
            Convert-VHD -path $Old_Path -DestinationPath $New_Path -ErrorAction Stop
        }
        catch {
            write-error $Error[0]
        }

        Write-Verbose "$(Get-Date): $name succesfully converted to a .vhd"

        if ($Confirm_Delete) {
            try {
                remove-item -Path $Old_Path -Force -ErrorAction Stop
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