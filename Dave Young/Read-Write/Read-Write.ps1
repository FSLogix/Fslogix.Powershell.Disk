#So the next question\challenge is can we do permissions read\write of a file to a \\server\path, this would be to validate storage is alive.
function Read-Write {
    [CmdletBinding()]
    param (
        [Parameter( Position = 0,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
                    [System.String]$Path
    )
    
    begin {
        Set-Strictmode -Version latest
    }
    
    process {

        if(!$Path){
            Write-Verbose "User did not specify path. Defaulting to '\\server\path'."
            $Path = "\\Server\Path"
        }else{
            if(-not(Test-Path -path $Path)){
                Write-Error "Could not find path: $Path." -ErrorAction Stop
            }else{ Write-Verbose "Validated Path: $Path" }
        }


        $Acl = Get-Acl -path $Path
        $Permissions = "Read", "Write"
        try {
            ## "None", "None" will apply the security setting only to the folder/file specified.
            ## "ContainerInherit, ObjectInherit", "None" will apply security setting to folder and subfolder/files
            ## "ContainerInherit, ObjectInherit", "InheritOnly" will apply security setting only to subfolder/files
            $Ar = New-Object system.Security.AccessControl.FileSystemAccessRule("Everyone", $Permissions, "None", "None", "Allow")
            $Acl.SetAccessRule($Ar)
        }
        catch {
            #Inherit doesn't work for files
            $Ar = New-Object system.Security.AccessControl.FileSystemAccessRule("Everyone", $Permissions, "Allow")
            $Acl.SetAccessRule($Ar)
        }
        Set-Acl -path $Path $ACL -ErrorAction Stop
        Write-Verbose "Set Read\Write file to $Path"
    }
    
    end {
    }
}