function Remove-FslDisk {
    <#
        .SYNOPSIS
        Deletes a virtual disk

        .PARAMETER Path
        Path to a disk or directory of disks

        .EXAMPLE
        Remove-FslDisk -path 'C:\Test1.vhd'
        Deletes the vhd, test1.vhd

        .EXAMPLE
        Remove-FslDisk -path 'C:\VHD'
        Deletes every virtaul disk within directory C:\VHD
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$path
    )

    begin {
        set-strictmode -Version latest
    }

    process {
        if(-not(test-path -path $path)){
            Write-Error "Could not find path: $path" -ErrorAction Stop
        }

        $VHDs = Get-FslVHD -path $path

        foreach($vhd in $VHDs){
            try{
                remove-item -path $vhd.path
                Write-Verbose "$(Get-Date): Removed $(split-path -path $vhd.path -leaf)"
            }catch{
                Write-Error $Error[0]
            }
        }
    }

    end {
    }
}