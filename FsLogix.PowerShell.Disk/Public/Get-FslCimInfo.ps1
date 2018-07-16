function Get-FslCimInfo {
    <#
        .SYNOPSIS
        Returns the CIM information

        .DESCRIPTION
        Obtains all the virtual hard disks or a specific disk and returns the cim information

        .PARAMETER VHDPath
        Directory to virtual hard disks or user specific virtual disk

        .PARAMETER CSVpath
        Optonal parameter to store cim information onto a csv document.
        Path to where the user would like the csv file to be located.
        User does not have to create csvfile, it will automatically be generated.

        .EXAMPLE
        Get-FslCimInfo -path 'C:\users\danie\VHD\test.vhd'
        Will output the cim information for test.vhd

        .EXAMPLE
        Get-FslCimInfo -path 'C:\users\danie\VHD\test.vhd' -csv 'C:\Users\Danie\Desktop\CimLogging.csv'
        Will output the cim inforamtion for test.vhd into Logging.csv onto the user's desktop

    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("path")]
        [System.String]$VHDpath,

        [Parameter(Position = 1)]
        [Alias("csv")]
        [System.String]$csvpath
    )

    begin {
        set-strictmode -version latest
    }

    process {

        $VHDs = get-fslvhd -path $VHDpath

        if((![System.String]::IsNullOrEmpty($csvpath)) -and ($csvpath -notlike "*.csv")){
            Write-Error "CSVpath: $csvpath must include .csv extension" -ErrorAction Stop
        }

        if($csvpath -ne ""){
            remove-item -Path $csvpath -Force -ErrorAction SilentlyContinue
        }

        foreach ($vhd in $VHDs) {

            ## Mount
            get-driveletter -VHDPath $vhd.path | Out-Null

            $disk = get-disk | Where-Object {$_.Location -eq $vhd.path}
            $Disk_Name = split-path -path $disk.Location -Leaf

            $out = $disk | select-object @{ N = 'VHD'; E = {$Disk_Name}},
            @{ N = 'CimClass'; E = {$_.CimClass}},
            @{ N = 'CimInstanceProperties'; E = {$_.CimInstanceProperties}},
            @{ N = 'CimSystemProperties'; E = {$_.CimSystemProperties}}

            if ($csvpath) {
                Write-Verbose "$(Get-Date): Succesfully obtained $Disk_Name's Cim information."
                $out | Export-Csv -Path $csvpath -NoTypeInformation -Append -Force
            }
            else {
                write-output $out | Format-List *
            }

            dismount-FslDisk -Path $vhd.path
        }
    }

    end {
    }
}