function Get-FslOstFile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.string]$path
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {
        $Host.PrivateData.WarningForegroundColor = "Red"

        Write-Verbose "Validating path: $path"
        if(-not(test-path -path $path)){
            Write-Error "Could not find path: $path"
        }
        Write-Verbose "Validated path: $path"

        Write-Verbose "Retrieving VHD(s)"
        ## Helper function get-fslvhd ##
        $VHDs = get-fslvhd -path $path
        if($null -eq $VHDs){
            Write-Warning "Could not find any VHD(s) in $path"
            exit
        }

        foreach($vhd in $VHDs){
            $DriveLetter = get-driveletter -path $vhd.path
            $osts = get-childitem -path (join-path $DriveLetter *.ost) -recurse

            if($null -eq $osts){
                Write-Warning "Could not find OSTs in $($vhd.path)"
            }else{
                try {
                    $count = $osts.count
                }
                catch [System.Management.Automation.PropertyNotFoundException] {
                    # When calling the get-childitem cmdlet, if the cmldet only returns one
                    # object, then it loses the count property, despite working on terminal.
                    $count = 1 
                }
                Write-Verbose "Retrieved $count Osts in $($vhd.path)"
            }
            try{
                ## Helper function dismount-fsldisk ##
                dismount-FslDisk -path $vhd.path
            }catch{
                Write-Error $Error[0]
            }
        }
    }
    
    end {
        $Host.PrivateData.WarningForegroundColor = "Yellow"
    }
}