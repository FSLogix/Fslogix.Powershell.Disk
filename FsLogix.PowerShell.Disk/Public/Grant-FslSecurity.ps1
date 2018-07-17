function Grant-FslSecurity {
    [CmdletBinding(DefaultParametersetName = 'None')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]$path,

        [Parameter(Position = 1, ParameterSetName = 'Block')]
        [Switch]$block,

        [Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'Block')]
        [System.String]$AccountName,

        [Parameter(Position = 3)]
        [switch]$unblock,

        [Parameter(Position = 4, ParameterSetName = 'ACL')]
        [Switch]$permissions,

        [Parameter(Position = 5, Mandatory = $true, ParameterSetName = 'ACL')]
        [Validateset("FullControl", "Modify", "Read", "write", "ReadAndExecute")]
        [Alias("PermissionType")]
        [string]$PERMISSION_TYPE,

        [Parameter(Position = 6, Mandatory = $true, ParameterSetName = 'ACL')]
        [Validateset("Allow", "Deny")]
        [String]$PERMISSION
    )

    begin {
        set-strictmode -version latest
    }

    process {
        if (-not(test-path -path $path)) {
            Write-Error "Could not find path: $path" -ErrorAction Stop
        }

        $VHDs = get-fslvhd -path $path
        foreach ($vhd in $VHDs) {
            if ($block) {
                ## Need to test if this works ##
                Block-FileShareAccess -Name $vhd.path -AccountName $AccountName
            }
            if ($unblock) {
                unblock-file -Path $vhd.path
            }
            if ($permissions) {

                $user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name #User account to grant permisions too.
                $acl = Get-Acl $path

                try {
                    ## 6/18 testing
                    ## Script works fine when granting allow or deny permissions   ##
                    ## HOWEVER, once granted deny permissions, than the file's ACL ##
                    ## Won't get changed. Is there a way to fix this?              ##
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
    }

    end {
    }
}