function Get-FslAttachedDisk {
    <#
        IS THIS FUNCTION REALLY NEEDED?
        AFTER THE UPDATES TO GET-FSLDISK/GET-FSLVHD?


        
        .SYNOPSIS
        Retrieves the attached disk's information

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk

        .PARAMETER Path
        Path to a directory of VHD's or user specified VHD
        If Path is not specified, then currently attached disks will be used.

        .PARAMETER CSVFile
        Optional parameter to have disk information exported to a csv file.
        User does not have to create csvfile, it will automatically be generated.

        .EXAMPLE
        Get-FslAttachedDisk
        Will output the user's currently attached disk information

        .EXAMPLE
        Get-FslAttachedDisko -path 'C:\Users\Danie\VHD\Test1.vhd'
        Will output the information about test1.vhd

        .EXAMPLE
        Get-FslAttachedDisk -path 'C:\Users\Danie\VHD\Test1.vhd' -CSVFile 'C:\Users\Danie\Desktop\logging.csv'
        Will output the information about test1.vhd into csv file logging.csv.
    #>
    [CmdletBinding(DefaultParametersetName = 'None')]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [System.String]$Path,

        [Parameter(Position = 1, ValueFromPipeline = $true)]
        [System.String]$Csvfile,

        [Parameter(Position = 4, ParameterSetName = 'index', Mandatory = $true)]
        [int]$Start,

        [Parameter(Position = 5, ParameterSetName = 'index', Mandatory = $true)]
        [int]$End

    )

    begin {
        ## Helper function to validate requirements ##
        set-strictmode -Version latest
    }

    process {

        $VHDInfo = $false
        $DiskInfo = $false
        $ExportCsv = $false

        if ((![System.string]::IsNullOrEmpty($path)) -and (-not(test-path -path $path))) {
            Write-Error "Could not find path: $path" -ErrorAction Stop
        }
        if (![System.string]::IsNullOrEmpty($path)) {

            ## Helper function to retrieve virtual disks
            $VHDs = get-fslVHD -path $Path -start $Start -end $End
            $VHDInfo = $true
        }
        else {

            ## Return all currently attached disks
            $AttachedDisks = Get-Disk | where-object {$_.Model -like "Virtual Disk*"}
            if ($null -eq $AttachedDisks) {
                Write-Warning "Could not find any virtual disks."
            }
            else {
                $Disks = $AttachedDisks.Location | get-fslvhd -start $Start -end $end
                $DiskInfo = $true
            }
        }

        if ($Csvfile -ne "") {
            $ExportCsv = $true
            remove-item -Path $Csvfile -Force -ErrorAction SilentlyContinue
        }

        if ($ExportCsv) {
            if ($Csvfile -notlike "*.csv") {
                Write-Error "CSV file path must include '.csv' extension." -ErrorAction Stop
            }
        }

        if ($VHDInfo) {
            foreach ($curvhd in $VHDs) {
                $name = split-path -path $curvhd.path -leaf
                $out = $curvhd | select-object  @{ N = 'ComputerName'; E = {$_.ComputerName}},
                @{ N = 'Name'; E = {$name}},
                @{ N = 'Location'; E = {$_.path}},
                @{ N = 'Format'; E = {$_.VhdFormat}},
                @{ N = 'Type'; E = {$_.VhdType}},
                @{ N = 'Size(GB)'; E = {$_.Size / 1gb}},
                @{ N = 'Size(MB)'; E = {$_.Size / 1mb}},
                @{ N = 'FreeSpace(GB)'; E = {[math]::round((($_.Size - $_.FileSize) / 1gb), 2)}},
                @{ N = 'FreeSpace(MB)'; E = {[math]::round((($_.Size - $_.FileSize) / 1mb), 2)}}
                if ($ExportCsv) {
                    $out | Export-Csv -Path $Csvfile -NoTypeInformation -Append -Force
                }
                else {
                    write-output $out
                }
            }
        }
        if ($DiskInfo) {
            foreach ($curvhd in $Disks) {
                $name = split-path -path $curvhd.path -leaf
                $out = $curvhd | select-object  @{ N = 'ComputerName'; E = {$_.ComputerName}},
                @{ N = 'Name'; E = {$name}},
                @{ N = 'Location'; E = {$_.path}},
                @{ N = 'Format'; E = {$_.VhdFormat}},
                @{ N = 'Type'; E = {$_.VhdType}},
                @{ N = 'Size(GB)'; E = {$_.Size / 1gb}},
                @{ N = 'Size(MB)'; E = {$_.Size / 1mb}},
                @{ N = 'FreeSpace(GB)'; E = {[math]::round((($_.Size - $_.FileSize) / 1gb), 2)}},
                @{ N = 'FreeSpace(MB)'; E = {[math]::round((($_.Size - $_.FileSize) / 1mb), 2)}}
                if ($ExportCsv) {
                    $out | Export-Csv -Path $Csvfile -NoTypeInformation -Append -Force
                }
                else {
                    write-output $out
                }
            }
        }

    }

    end {
    }
}