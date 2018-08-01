function Set-FslLabel {
    <#
        .SYNOPSIS
        Labels a virtuals disk

        .DESCRIPTION
        Changes the name of the virtual disk's label to the user's account name.

        .PARAMETER FslUser
        The Active directory user's account name.

        .PARAMETER VHD
        Path to the user's associated virtaul disk

        .EXAMPLE
        Set-FslLabel -user 'Daniel' -Path 'C:\Users\danie\Documents\VHDModuleProject\ODFCTest2\Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811.vhd'
        Set's the label of the virtual disk 'Daniel_S-0-2-26-1944519217-1788772061-1800150966-14811' to Daniel.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][Alias("user")][System.String]$FslUser,

        [Parameter(Position = 1,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][Alias("Path")][System.String]$VHD
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {

        ## FsLogix private function, get-driveletter, will help with error handling.
        $DriveLetter = get-driveletter -VHDPath $VHD
        if ($DriveLetter.length -ne 3) {
            ## returned guid
            $diskID = (get-disk | Where-Object {$_.Location -eq $path}).Guid
            $Volume = get-volume | Where-Object {$_.Path -like "*$diskId*"}
            $Volume | Set-Volume -NewFileSystemLabel $FslUser
        }
        else {
            $DriveLabel = "Label.exe " + $DriveLetter.substring(0, 1) + ": " + $FslUser
            Write-Verbose "Invoking: $Drivelabel"
            Invoke-Expression -Command $DriveLabel
        }

        Write-Verbose "$(split-path -path $VHD -leaf)'s label has been labeled to: $FslUser"
    }
    
    end {
    }
}