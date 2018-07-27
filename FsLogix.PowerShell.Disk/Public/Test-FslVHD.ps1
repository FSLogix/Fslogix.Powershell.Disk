function Test-FslVHD {
    <#
        .SYNOPSIS
        Returns if VHD is valid or contains any problems.

        .DESCRIPTION
        Created by Daniel Kim @ FSLogix
        Github: https://github.com/FSLogix/Fslogix.Powershell.Disk
    #>
    [CmdletBinding(DefaultParameterSetName = 'none')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.string]$path,

        [Parameter(Position = 1,ParameterSetName = 'index', Mandatory = $true)]
        [int]$Start,

        [Parameter(Position = 2,ParameterSetName = 'index', Mandatory = $true)]
        [int]$End
    )

    begin {
        set-strictmode -Version latest
    }

    process {

        if(-not(test-path -Path $path)){
            Write-Error "Could not find path: $path" -ErrorAction Stop
        }

        ## Helper function Get-FslVHD/Get-FslDisk will help handle error cases"

        $VHDs = Get-FslVHD -path $path -start $start -end $end

        foreach($vhd in $VHDs){
            $Name = split-path -path $vhd.path -leaf
            $output = Test-VHD -path $vhd.path
            if($output){
                Write-Verbose "$(Get-Date): $Name is healthy"
            }else{
                Write-Warning "$(Get-Date): $name is unhealthy"
            }
            Write-Output $output
        }
    }

    end {
    }
}