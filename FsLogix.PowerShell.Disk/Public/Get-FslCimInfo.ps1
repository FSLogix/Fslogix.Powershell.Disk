function Get-FslCimInfo {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
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

        if(($csvpath -ne "") -and ($csvpath -notlike "*.csv")){
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
                Write-Verbose "Succesfully obtained $Disk_Name's Cim information."
                $out | Export-Csv -Path $csvpath -NoTypeInformation -Append -Force
            }
            else {
                write-output $out | fl *
            }

            dismount-FslDisk -Path $vhd.path
        }
    }
    
    end {
    }
}