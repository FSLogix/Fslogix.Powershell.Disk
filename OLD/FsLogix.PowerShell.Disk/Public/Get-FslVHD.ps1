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

        .PARAMETER Path
        Path to a specified VHD or directory of VHD

        .PARAMETER Start
        Optional parameter to specify a start index 

        .PARAMETER End
        Optional parameter to speicfy an end index

        .PARAMETER Full
        Optional switch parameter to obtain full information.
        Will result in performance slow down

        .EXAMPLE
        Get-FslVHD -path C:\Users\danie\Documents\VHDModuleProject\ODFCTest2
        Retreives all the VHD's within the folder 'ODFCTest2'

    #>
    [CmdletBinding(DefaultParametersetName = 'none')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$path,

        [Parameter(Position = 1, Mandatory = $true, ParameterSetName = 'index')]
        [uint16]$start,

        [Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'index')]
        [uint16]$end,

        [Parameter(Position = 3)]
        [Switch]$full
    )

    begin {
        set-strictmode -Version latest
    }

    process {

        if (-not(test-path -path $path)) {
            write-error "Path: $path is invalid." -ErrorAction Stop
        }
        $VHDs = get-childitem -path $path -filter "*.vhd*" -Recurse
        if ($null -eq $VHDs) {
            Write-Warning "Could not find any VHDs in path: $path"
            exit
        }
        else {
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

            if ($start -eq 1) {
                $start = 0
            }
            if ($start -gt $end) {
                Write-Error "Starting Index: $start cannot be greater than ending index: $end." -ErrorAction Stop
            }

            if ($start -gt $GC_count) {
                Write-Error "Starting Index: $Start cannot be greater than to total count of disks: $GC_Count." -ErrorAction Stop
            }
            if ($end -gt $GC_count) {
                Write-Warning "Ending index is greater than total VHD's found. Ending index is now: $GC_Count"
                $end = $GC_count
            }

            if ($start -eq 0) {
                Write-Verbose "$(Get-Date): Obtaining VHD's from starting index: 1 to ending index: $End."
            }
            else {
                Write-Verbose "$(Get-Date): Obtaining VHD's from starting index: $Start to ending index: $End."
            }

            ## If it's a small number, this seems to run faster
            if ($GC_count -gt 10) {
                $VHDs_Skipped = $VHDs | select-object -Skip $start
                $VHD_Adjusted_List = $VHDs_Skipped | select-object -SkipLast ($GC_count - $end)
                if($full){
                    $VhdDetails = $VHD_Adjusted_List.fullname | get-fsldisk -Full
                }else{
                    $VhdDetails = $VHD_Adjusted_List.fullname | get-fsldisk
                }
                
            }
            else { ## But if it's a large number of disks, this seems to run faster.
                $DiskHashTable = @{}
                $counter = 1
                foreach ($vhd in $VHDs) {
                    $DiskHashTable.add($vhd.fullname, $counter++)
                    if ($counter -gt $End) {
                        break
                    }
                }
                $Vhdlist = $DiskHashTable.GetEnumerator() | Sort-object -property Name
                if($full){
                    $VhdDetails = (($vhdlist).where( {$_.value -ge $Start -and $_.Value -le $End})).Key | get-fsldisk -Full
                }else{
                    $VhdDetails = (($vhdlist).where( {$_.value -ge $Start -and $_.Value -le $End})).Key | get-fsldisk
                }
                
            }
        }
        else {
            if($full){
                $VhdDetails = $VHDs.FullName | get-fsldisk -Full
            }else{
                $VhdDetails = $VHDs.FullName | get-fsldisk
            }
        }
        if ($null -eq $VhdDetails) {
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