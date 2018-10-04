function Add-FslPermissions {
    [CmdletBinding(DefaultParameterSetName = 'AdUser')]
    param (
        [Parameter( Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'User')]
        [System.String]$User,

        [Parameter( Position = 1,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'File')]
        [System.String]$File,

        [Parameter( Position = 2,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Folder')]
        [System.String]$Folder,

        [Parameter( Position = 3,
            ParameterSetName = 'Folder')]
        [Switch]$Recurse
    )
    
    begin {
        Set-StrictMode -Version Latest
        #Requires -RunAsAdministrator
        #Requires -Modules "ActiveDirectory"
    }
    
    process {

        Try {
            $Ad_User = Get-ADUser -Identity $User -ErrorAction Stop | Select-Object -ExpandProperty SamAccountName
        }
        Catch {
            Write-Error $Error[0]
        }

        Switch ($PSCmdlet.ParameterSetName) {
            File {
                if (-not(test-path -path $file)) {
                    Write-Error "Could not find path: $File" -ErrorAction Stop
                }
                else {
                    $File_isFile = Get-item -path $file
                    if ($File_isFile.Attributes -ne "Archive") {
                        Write-Error "$($File_isFile.BaseName) is not a file."
                    }
                }

                Try {
                    $ACL = Get-Acl $File
                    $Ar = New-Object system.Security.AccessControl.FileSystemAccessRule($Ad_User, "FullControl", "Allow")
                    $Acl.Setaccessrule($Ar)
                    Set-Acl -Path $File $ACL
                    Write-Verbose "Assigned permissions for user: $Ad_User"
                }
                catch {
                    Write-Error $Error[0]
                }
            }

            Folder {
                if (-not(test-path -path $folder)) {
                    Write-Error "Could not find path: $Folder" -ErrorAction Stop
                }
                
                $Folder_isFolder = get-item -path $Folder
                if ($Folder_isFolder.Attributes -ne 'Directory') {
                    Write-Error "$($Folder_isFolder.BaseName) is not a folder." -ErrorAction Stop
                }
                
                if ($Recurse) {
                    $Directory = $( Get-Item $Folder 
                                    Get-ChildItem $folder -recurse)                    
                }else {                        
                    $Directory = $Folder_isFolder
                }

                foreach ($dir in $Directory) {
                    Try {
                        $ACL = Get-Acl $dir.fullname
                        $Ar = New-Object system.Security.AccessControl.FileSystemAccessRule($Ad_User, "FullControl", "Allow")
                        $Acl.Setaccessrule($Ar)
                        Set-Acl -Path $dir.fullname $ACL
                        Write-Verbose "Assigned permissions for user: $Ad_User"
                    }catch {
                        Write-Error $Error[0]
                    }
                }
                
            }#folder
        }#switch
    }#process
}