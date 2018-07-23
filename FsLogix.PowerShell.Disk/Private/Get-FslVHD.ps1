function Get-FslVHD {
    <#
        .SYNOPSIS
        Retrives all VHD's within a path and returns their information.

        .DESCRIPTION
        Searches in a given path for all VHD's. User can either input a directory path or
        a path to an indivudal VHD. Once all the VHD's are found, if found, return the amount
        found and then outputs the VHD's information.

        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .EXAMPLE
        Get-FslVHD -path C:\Users\danie\Documents\VHDModuleProject\ODFCTest2
        Retreives all the VHD's within the folder 'ODFCTest2'
    #>
    [CmdletBinding(DefaultParametersetName='none')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$path,

        [Parameter(Position = 1, Mandatory = $true, ParameterSetName = 'index')]
        [uint16]$start,

        [Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'index')]
        [uint16]$end
    )

    begin {
        set-strictmode -Version latest
    }

    process {

        if(-not(test-path -path $path)){
            write-error "Path: $path is invalid." -ErrorAction Stop
        }
        $VHDs = get-childitem -path $path -filter "*.vhd*" -Recurse
        if($null -eq $VHDs){
            Write-Warning "Could not find any VHDs in path: $path"
            exit
        }else{
            try {
                $GC_count = $VHDs.count
            }
            catch [System.Management.Automation.PropertyNotFoundException] {
                # When calling the get-childitem cmdlet, if the cmldet only returns one
                # object, then it loses the count property, despite working on terminal.
                $GC_count = 1
            }
        }

        if ($Start -ne 0 -and $End -ne 0) {

            if($start -gt $end){
                Write-Error "Starting Index: $start cannot be greater than ending index: $end." -ErrorAction Stop
            }

            if($start -gt $GC_count){
                Write-Error "Starting Index: $Start cannot be greater than to total count of disks: $GC_Count." -ErrorAction Stop
            }

            $DiskHashTable = @{}
            $counter = 1
            foreach($vhd in $VHDs){
                $DiskHashTable.add($vhd.fullname,$counter++)
                if($counter -gt $End){
                    break
                }
            }
            Write-Verbose "$(Get-Date): Obtaining VHD's from starting index: $Start to ending index: $End."
            $Vhdlist = $DiskHashTable.GetEnumerator() | Sort-object -property Name
            $VhdDetails = ($vhdlist | Where-Object {$_.value -ge $Start -and $_.Value -le $End}).Key | get-fsldisk
        }else{
            $VhdDetails = $VHDs.FullName | get-fsldisk
        }
        if($null -eq $VhdDetails){
            Write-Warning "Could not retrieve any VHD's in $path"
            exit
        }
        try {
            $count = $VhdDetails.count
        }
        catch [System.Management.Automation.PropertyNotFoundException] {
            # When calling the get-childitem cmdlet, if the cmldet only returns one
            # object, then it loses the count property, despite working on terminal.
            $count = 1
        }
        write-verbose "$(Get-Date): Retrieved $count VHD(s)."

        Write-Output $VhdDetails
    }

    end {
    }
}