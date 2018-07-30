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
    #[CmdletBinding()]
    [CmdletBinding(DefaultParametersetName = 'None')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("path")]
        [System.String]$VHDpath,

        [Parameter(Position = 1)]
        [Alias("csv")]
        [System.String]$csvpath,

        [Parameter(Position = 2,ParameterSetName = 'index', Mandatory = $true)]
        [int]$Start,

        [Parameter(Position = 3,ParameterSetName = 'index', Mandatory = $true)]
        [int]$End
    )

    begin {
        set-strictmode -version latest
    }

    process {

        if((![System.String]::IsNullOrEmpty($csvpath)) -and ($csvpath -notlike "*.csv")){
            Write-Error "CSVpath: $csvpath must include .csv extension" -ErrorAction Stop
        }

        if((![System.String]::IsNullOrEmpty($csvpath)) -and (test-path $csvpath)){
            remove-item -Path $csvpath -Force -ErrorAction SilentlyContinue
        }

        $VHDs = get-fslvhd -path $VHDpath -start $Start -end $End

        foreach ($vhd in $VHDs) {

            ## Mount
            if(!$vhd.attached){
                Mount-VHD -Path $vhd.path
            }

            $disk = (get-disk).where({$_.Location -eq $vhd.path})
            $Disk_Name = split-path -path $vhd.path -Leaf

            $out = $disk | select-object @{ N = 'VHD'; E = {$Disk_Name}},
                                         @{ N = 'CimClass'; E = {$_.CimClass}},
                                         @{ N = 'CimInstanceProperties'; E = {$_.CimInstanceProperties}},
                                         @{ N = 'CimSystemProperties'; E = {$_.CimSystemProperties}}


            Write-Verbose "$(Get-Date): Succesfully obtained $Disk_Name's Cim information."
            if ($csvpath) {
                $out | Export-Csv -Path $csvpath -NoTypeInformation -Append -Force
            }
            else { write-output $out }

            dismount-FslDisk -Path $vhd.path
        }
    }

    end {
    }
}