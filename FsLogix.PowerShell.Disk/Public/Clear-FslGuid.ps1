function Clear-FslGuid {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
            if(-not(test-path -path $_)){
                Throw "Could not find Guid path: $_"
            }
        })][System.String]$GuidPath       
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {
        if(!$GuidPath){
            $GuidPath = 'C:\programdata\FsLogix\FslGuid'
        }
      

        $VHD_Guid_path = get-childitem -path $GuidPath
        if($null -eq $VHD_Guid_path){
            Write-Warning -Message "Guid is already cleared"
            exit
        }
        foreach($path in $VHD_Guid_path){
            Remove-item -Path $Path -Force -ErrorAction SilentlyContinue
        }
        Write-Verbose "Cleared all Guid paths in $GuidPath."
    }
    
    end {
    }
}