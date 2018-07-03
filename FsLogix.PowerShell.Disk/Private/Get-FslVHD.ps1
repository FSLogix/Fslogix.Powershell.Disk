function Get-FslVHD {
    <#
        .SYNOPSIS
        Retrives all VHD's within a path and returns their information.
        
        .DESCRIPTION
        Searches in a given path for all VHD's. User can either input a directory path or
        a path to an indivudal VHD. Once all the VHD's are found, if found, return the amount
        found and then outputs the VHD's information. 
    #>
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
            # When calling the get-childitem cmdlet, if the cmldet only returns one
            # object, then it loses the count property, despite working on terminal.
            $count = 1 
        }
        write-verbose "Retrieved $count VHD(s)."
        
        Write-Output $VhdDetails
    }
    
    end {
        
    }
}