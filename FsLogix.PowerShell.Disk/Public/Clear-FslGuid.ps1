function Clear-FslGuid {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][System.String]$GuidPath       
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {
        if(!$GuidPath){
            $GuidPath = 'C:\programdata\FsLogix\FslGuid'
        }
        if(-not(test-path -path $GuidPath)){
            Write-Error "Could not find Guid path: $GuidPath" -ErrorAction Stop
        }

        $VHD_Guid_path = (get-childitem -path $GuidPath -Recurse).FullName
        foreach($path in $VHD_Guid_path){
            Remove-item -Path $Path -Force -ErrorAction SilentlyContinue
        }
        Write-Verbose "Cleared all Guid paths in $GuidPath."
    }
    
    end {
    }
}