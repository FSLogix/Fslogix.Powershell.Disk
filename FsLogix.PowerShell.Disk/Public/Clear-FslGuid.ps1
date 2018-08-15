function Clear-FslGuid {
    <#
        .SYNOPSIS
        Deletes all the guid folders within "C:\programdata\FsLogix\FslGuid"

        .DESCRIPTION
        By deleting the guid folderes, this also removes the partition access path
        that was generated.
        
        .EXAMPLE
        Clear-fslguid
        Removes all guid folders.
    #>
    [CmdletBinding()]
    param (       
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {
        
        $GuidPath = "C:\programdata\FsLogix\FslGuid"

        if (-not(test-path $GuidPath)) {
            Write-Error "Could not found path: $GuidPath" -ErrorAction Stop
        }
      

        $VHD_Guid_path = get-childitem -path $GuidPath | Where-Object {$_.LinkType -eq 'Junction'} | Select-Object -Property FullName
        if ($null -eq $VHD_Guid_path) {
            Write-Warning -Message "Guid is already cleared"
        }
        else {
            foreach ($path in $VHD_Guid_path.FullName) {
                Remove-item -Path $Path -Force -Recurse #-ErrorAction SilentlyContinue
            }
            Write-Verbose "Cleared all Guid paths in $GuidPath."
        }
    }
    
    end {
    }
}