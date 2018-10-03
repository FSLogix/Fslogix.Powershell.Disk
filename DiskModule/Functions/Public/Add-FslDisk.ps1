function Add-FslDisk {
    <#
        Create VHD... ODFC_Samaccountname.vhdx
    #>
    [CmdletBinding()]
    param (
        [Parameter( Position = 0, 
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [System.String]
        $User,

        [Parameter( Position = 1,
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [System.String]
        $Destination,

        [Parameter( Position = 2,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [Alias("Size")]
        [System.int64]
        $SizeInMB,

        [Parameter( Position = 3 )]
        [ValidateRange(0,1)]
        [int]$Type,

        [Parameter (Position = 4)]
        [String]$Label,

        [Parameter( Position = 5 )]
        [Switch]$Passthru
    )
    
    begin {
        #Requires -RunAsAdministrator
        #Requires -Modules "ActiveDirectory"
    }
    
    process {

        try {
            $InstallPath = (Get-ItemProperty HKLM:\SOFTWARE\FSLogix\Apps -ErrorAction Stop).InstallPath
        }
        catch {
            Write-Error "FsLogix Applications not found." -ErrorAction Stop
        }
        push-Location
        Set-Location -path $InstallPath
        
        $frxPath = Join-Path ($InstallPath) ("frx.exe")
        if ( -not (Test-Path $frxPath )) {
            Write-Error 'frx.exe Not Found' -ErrorAction Stop
        }
        
        Try{
            $AdUser = Get-Aduser -Identity $User -ErrorAction Stop
            $SID = $AdUser.SID
            $SamAccountName = $AdUser.samaccountname

        }catch{
            Write-Error $Error[0]
        }
        
        if(!$PSBoundParameters.ContainsKey("Type")){
            $Type = 1
        }

        if(!$PSBoundParameters.ContainsKey("SizeInMb")){
            $SizeInMB = 30000
        }

        if(!$PSBoundParameters.ContainsKey("Label")){
            $Label = $SamAccountName
        }

        $VHD_name   = "ODFC_$($SamAccountName).vhdx"
        $VHD_Folder = "$($SamaccountName)_$($SID)"

        $VHD_FolderPath = join-path ($Destination) ($VHD_Folder)
        $VHD_Path = join-path ($VHD_FolderPath) ($VHD_name)
        
        $FrxCommand = " .\frx.exe create-vhd -filename $VHD_Path -size-mbs=$SizeInMB -dynamic=$type -label $Label"
        Invoke-expression -command $FrxCommand
        Add-FslPermissions -Folder $VHD_FolderPath -Recurse

        if($Passthru){
            Get-FslDisk -path $VHD_Path
        }

        Pop-Location
    }
}