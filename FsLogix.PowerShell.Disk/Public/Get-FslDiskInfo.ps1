function Get-FslDiskInfo {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [System.String]$Path,
        
        [Parameter(Position = 1, ValueFromPipeline = $true)]
        [System.String]$Csvfile
    )
    
    begin {
        ## Helper function to validate requirements ##
        set-strictmode -Version latest
    }
    
    process {

        $VHDInfo = $false
        $DiskInfo = $false
        $ExportCsv = $false

        if($path -ne "" -and (-not(test-path -path $path))){
            Write-Error "Could not find path: $path" -ErrorAction Stop
        }
        if ($path -ne "") {

            ## Helper function to retrieve virtual disks
            $VHDs = get-fslVHD -path $Path
            $VHDInfo = $true
        }
        else {

            ## Return all currently attached disks
            $Disks = Get-PSDrive | Where-Object {$_.Provider.Name -like "filesystem"}
            $DiskInfo = $true
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
                $out = $curvhd | select-object @{ N = 'ComputerName'; E = {$_.ComputerName}},
                                            @{ N = 'Name';          E = {$name}},
                                            @{ N = 'Location';      E = {$_.path}},
                                            @{ N = 'Format';        E = {$_.VhdFormat}},
                                            @{ N = 'Type';          E = {$_.VhdType}},
                                            @{ N = 'Size(GB)';      E = {$_.Size / 1gb}},
                                            @{ N = 'Size(MB)';      E = {$_.Size / 1mb}},
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
            foreach ($disk in $Disks) {

                $out = $disk | Select-Object @{ N = 'Drive'; E = {$_.Root    }},
                                            @{ N = 'Used(GB)'; E = {$_.Used / 1gb}},
                                            @{ N = 'Used(MB)'; E = {$_.Used / 1mb}},
                                            @{ N = 'Free(GB)'; E = {$_.Free / 1gb}},
                                            @{ N = 'Free(MB)'; E = {$_.Free / 1mb}}
                                             
                if ($ExportCsv) {
                    $out | Export-Csv -path $Csvfile -NoTypeInformation -Append -Force
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