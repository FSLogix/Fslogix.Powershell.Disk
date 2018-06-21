function Get-FslVHD {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$path
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {

        if(-not(test-path -path $path)){
            write-error "Path: $path is invalid."
            exit
        }
        
        $VHDs = get-childitem -path $path -filter "*.vhd*" -Recurse
        if($null -eq $VHDs){
            write-error "Could not find any VHDs in path: $path"
            exit
        }

        $VhdDetails = $VHDs.FullName | get-fsldisk
        try {
            $count = $VhdDetails.count
        }
        catch [System.Management.Automation.PropertyNotFoundException] {
            ##When calling the get-childitem cmdlet, if the cmldet only returns one
            #object, then it loses the count property, despite working on terminal.
            $count = 1 
        }
        write-verbose "Retrieved $count VHD(s)."

        Write-Output $VhdDetails
    }
    
    end {
        
    }
}