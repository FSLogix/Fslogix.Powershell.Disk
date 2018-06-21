function ConvertTo-FslDisk {
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
        set-strictmode -Version latest
        
        $Convert_To_VHD = $false
        $Convert_To_VHDx = $false
        $Delete_Existing_VHD = $false
        $Delete_Old_VHD = $false

    }
    
    process {
        if($ConvertTo -eq "vhd"){
            $Convert_To_VHD = $true
        }

        if($ConvertTo -eq "vhdx"){
            $Convert_To_VHDx = $true
        }
        
        if($Remove_Old -eq "true"){
            $Delete_Old_VHD = $true
        }

        if($Remove_Existing -eq "true"){
            $Delete_Existing_VHD = $true
        }

        if(-not(test-path -path $Path)){
            Write-Error "Path: $path is invalid. Exiting script..."
            exit
        }       

        ## Get VHD(s) within Path ##
        $VHDs = get-childitem -Path $Path -filter "*.vhd*"
        if($null -eq $VHDs){
            Write-Error "Could not find any VHD's in $path"
            exit
        }

        if($Convert_To_VHD){

            Write-Verbose "Obtaining all .vhdx's in $path"
            $VhdDetails = $VHDs.FullName | get-fsldisk | Where-Object {$_.vhdformat -eq "VHDX"}

        }else{

            write-verbose "Obtaining all .vhd's in $path"
            $VhdDetails = $VHDs.FullName | get-fsldisk | where-object {$_.vhdformat -eq "VHD"}

        }
        if($null -eq $VhdDetails){
            Write-Error "Already the same type, cannot convert."
            exit
        }

        Write-Verbose "Gathered all VHD(s) information."
        
        ## Convert to VHD                      ##
        ## Helper functions will handle errors ##
        
        #This functionality is the exact same as the one below
        #Should figure out which one is faster and use faster one.
        <#foreach($vhd in $VhdDetails){
            if($Convert_To_VHD){
                convertTo-VHD -path $vhd.path -confirm $Remove_Old -overwrite $Remove_Existing
            }else{
                convertTo-VHDx -path $vhd.path -confirm $Remove_Old -overwrite $Remove_Existing
            }
        }#>
        if($Convert_To_VHD){
            foreach($vhd in $VhdDetails){
                convertTo-VHD -path $vhd.path -confirm $Remove_Old -overwrite $Remove_Existing
            }
        }else{
            foreach($vhd in $VhdDetails){
                convertTo-VHDx -path $vhd.path -confirm $Remove_Old -overwrite $Remove_Existing
            }
        }
    }
    
    end {
        Write-Verbose "Finished ConvertTo-FslDisk script. Exiting..."
    }
}
