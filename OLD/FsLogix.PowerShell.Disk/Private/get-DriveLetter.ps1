function get-driveletter {
    <#
        .NOTES
        Created on 6/6/18
        Created by Daniel Kim @ FSLogix
        Created by Jim Moyle @ FSLogix
        https://github.com/FSLogix/Fslogix.Powershell.Disk
        .SYNOPSIS
        Obtains a virtual disk and returns the Drive Letter associated with it.
        If either Drive Letter is null or invalid, the script will assign the
        next available drive letter.
        .DESCRIPTION
        This function can be added to any script that requires mounting
        a vhd and accessing it's contents.
        .PARAMETER VHDPath
        The target path for VHD location.
        .EXAMPLE
        Get-Driveletter -path \\server\share\ODFC\vhd1.vhdx
        Will return the drive letter associated with vhd1.vhdx
        If none exists, then the script will assign the next available driveletter to the disk.
    #>

    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("path")]
        [string]$VHDPath
    )
    begin {
        Set-StrictMode -Version Latest
    }
    process {
        if (-not(test-path $VHDPath)) {
            Write-Error "Can not find path: $VHDPath" -ErrorAction Stop
        }

        
        $Name = split-path -path $VHDPath -leaf
        $VHD = get-fsldisk $VHDPath
        if ($VHD.Attached) {
            $mount = Get-Disk | Where-Object {$_.Location -eq $VHDPath}
        }
        else {
            $Mount = Mount-DiskImage -ImagePath $VHDPath -PassThru -ErrorAction Stop | get-diskimage
        }     
        $DiskNumber = $mount.Number
        
        $DriveLetter = Get-Partition -DiskNumber $DiskNumber | Select-Object -ExpandProperty AccessPaths | select-object -first 1

        ## If the VHD does not have a drive letter assigned. Using GUID.
        if (($null -eq $DriveLetter) -or ($driveLetter -like "*\\?\Volume{*")) {
            Write-Verbose "Did not receive valid driveletter: $Driveletter. Assigning guid."
            
            $guid_ID = (New-Guid).guid

            $Partitions = get-partition -DiskNumber $DiskNumber | Where-Object {$_.type -eq 'Basic'}
            $PartFolder = join-path "C:\programdata\fslogix\FslGuid" $guid_ID
            
            if(test-path -path $PartFolder){
                Remove-item -path $PartFolder -Force
            }
            
            New-Item -ItemType Directory -Path $PartFolder | Out-Null 
            Add-PartitionAccessPath -InputObject $Partitions -AccessPath $PartFolder -ErrorAction Stop | Out-Null
    
            $DriveLetter = $PartFolder
        }

        if ($DriveLetter.Length -eq 3) {
            Write-Verbose "$(Get-Date): $name mounted on drive letter [$DriveLetter]"
        }
        else {
            Write-Verbose "$(Get-Date): $name mounted on path [$DriveLetter]"
        }
        Write-Output $driveLetter
        
    }#end process
    end {
    }
}