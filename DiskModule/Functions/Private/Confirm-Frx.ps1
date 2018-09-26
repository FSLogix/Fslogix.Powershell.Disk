function Confirm-Frx {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        set-strictmode -version latest
    }
    
    process {

        try {
            $InstallPath = (Get-ItemProperty HKLM:\SOFTWARE\FSLogix\Apps -ErrorAction Stop).InstallPath
        }
        catch {
            Write-Error "FsLogix Applications not found. Please intall FsLogix applications."
            exit
        }
        push-Location
        Set-Location -path $InstallPath
        
        $frxPath = Join-Path ($InstallPath) ("frx.exe")
        if ( -not (Test-Path $frxPath )) {
            Write-Error 'frx.exe Not Found. Please reinstall FsLogix Applications.' -ErrorAction Stop
            exit
        }
    }
    
    end {
    }
}