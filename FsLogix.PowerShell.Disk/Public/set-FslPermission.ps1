function set-FslPermissions {
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string]$path,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)]
        [Validateset("FullControl", "Modify", "Read", "write","ReadAndExecute")]
        [Alias("PermissionType")]
        [string]$PERMISSION_TYPE,

        [Parameter(Position = 2, Mandatory = $true, ValueFromPipeline = $true)]
        [Validateset("Allow", "Deny")]
        [String]$PERMISSION

    )
    begin {
        set-strictmode -Version latest

        if(-not(test-path -path $path)){
            write-error "Path: $path is invalid."
            exit
        }
    }
           
    process {
                
        $user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name #User account to grant permisions too.
        $acl = Get-Acl $path
                
        try {   #6/18 testing
                #IF A FILE LOST CONTROL RIGHTS, THE SCRIPT WON'T WORK.
                #THE SCRIPT WILL RUN FINE, BUT AFTER RUNNING THE SCRIPT WITH PARAMETERS: FULL CONTROL/ALLOW
                #THE FILE/FOLDER WON'T UPDATE. NEED TO FIX THIS
            write-verbose "Assigning Permissions to $path"
            $Access = New-Object System.Security.AccessControl.FileSystemAccessRule($user, $PERMISSION_TYPE, $PERMISSION)
            $acl.SetAccessRule($Access)
            $acl | Set-Acl -Path $path 
            write-verbose "Successfully assigned permissions."
        }
        catch {
            write-error $Error[0]
        }   
    }
}