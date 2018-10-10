function Set-FslFileShare {
    <#
        .SYNOPSIS
        Sets the windows fileshare share permisisons

        .DESCRIPTION
        Set's the fileshare folder and it's contents to these permissions:

        David Young mentioned these settings have been working without fail.

        *NTFS Permissions:CREATOR OWNER - Full Control (Apply onto: Subfolders and Files Only)
        *System - Full Control (Apply onto: This Folder, Subfolders and Files)
        *Domain Admins - Full Control (Apply onto: This Folder, Subfolders and Files)
        *Everyone - Create Folder/Append Data (Apply onto: This Folder Only)
        *Everyone - List Folder/Read Data (Apply onto: This Folder Only)
        *Everyone - Read Attributes (Apply onto: This Folder Only)
        *Everyone - Traverse Folder/Execute File (Apply onto: This Folder Only)
        *Share permissions as: Everyone - Full Control

        .PARAMETER Name
        The name of the fileshare folder.
        If user types in console, get-wmiobject -Class win32_share,
        this will return the names of all of the current computer's fileshares.

        .PARAMETER ComputerName
        Optional parameter for the user's computer name.
        This option can be used if user wants to remotely connect to a computer.
        If computername isn't specified, local computer name will be defaulted.

        .PARAMETER AdGroup
        Active Directory group name. Defaulted to 'Domain Admins' unless user specified.

        .PARAMETER Path
        Path to generate log file. Defaulted to user's temporary folder with the name FslPermissions unless user specified.

        .EXAMPLE
        Set-FslFileShare -name 'Users' -computername 'Daniel' -AdGroup 'FsLogix'
        The script will look for the fileshare named, 'Users'. Once the fileshare is found,
        the permissions(Shown in the description)will be set.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][System.String]$Name,

        [Parameter(Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][System.String]$ComputerName,

        [Parameter(Position = 2,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][System.String]$AdGroup,

        [Parameter(Position = 3,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][System.String]$path = "$env:TEMP\FslPermissions.log"
    )
    
    begin {
        set-strictmode -Version latest
        if ([System.String]::IsNullOrEmpty($ComputerName)) {
            $ComputerName = $env:COMPUTERNAME
        }
        function global:Get-DomainAdminName () {
            # Note: Created by Kevin. Code from: ProfileMigration script
            #       
            #       this script obtains SID of the primary AD domain for the local computer. It works both
            #       if the local computer is a domain member (DomainRole = 1 or DomainRole = 3)
            #       or if the local computer is a domain controller (DomainRole = 4 or DomainRole = 4).
            #       The code works even under local user account and does not require calling user
            #       to be domain account.
        
            [string] $domainSID = $null
        
            [int] $domainRole = Get-WmiObject Win32_ComputerSystem | Select-Object -Expand DomainRole
            [bool] $isDomainMember = ($domainRole -ne 0) -and ($domainRole -ne 2)
        
            if ($isDomainMember) {
        
                [string] $domain = Get-WmiObject Win32_ComputerSystem | Select-Object -Expand Domain
                [string] $krbtgtSID = (New-Object Security.Principal.NTAccount $domain\krbtgt).Translate([Security.Principal.SecurityIdentifier]).Value
                $domainSID = $krbtgtSID.SubString(0, $krbtgtSID.LastIndexOf('-'))
            }
        
        
            $domainSID += "-512"
            $Admin = Get-ADGroup -Filter {SID -like $StrDomainSid} | Select-Object Name, SID
            $Admin.Name
        
        }
        function Global:Write-Log {
            <#
                .SYNOPSIS
                CREATED BY JIM MOYLE
                Single function to enable logging to file.
                .DESCRIPTION
                The Log file can be output to any directory. A single log entry looks like this:
                2018-01-30 14:40:35 INFO:    'My log text'
                Log entries can be Info, Warn, Error or Debug
                The function takes pipeline input and you can even pipe exceptions straight to the function for automatic logging.
                The $PSDefaultParameterValues built-in Variable can be used to conveniently set the path and/or JSONformat switch at the top of the script:
                $PSDefaultParameterValues = @{"Write-Log:Path" = 'C:\YourPathHere'}
                $PSDefaultParameterValues = @{"Write-Log:JSONformat" = $true}
                .PARAMETER Message
                This is the body of the log line and should contain the information you wish to log.
                .PARAMETER Level
                One of four logging levels: INFO, WARN, ERROR or DEBUG.  This is an optional parameter and defaults to INFO
                .PARAMETER Path
                The path where you want the log file to be created.  This is an optional parameter and defaults to "$env:temp\PowershellScript.log"
                .PARAMETER StartNew
                This will blank any current log in the path, it should be used at the start of a script when you don't want to append to an existing log.
                .PARAMETER Exception
                Used to pass a powershell exception to the logging function for automatic logging
                .PARAMETER JSONFormat
                Used to change the logging format from human readable to machine readable format, this will be a single line like the example format below:
                In this format the timestamp will include a much more granular time which will also include timezone information.
                {"TimeStamp":"2018-02-01T12:01:24.8908638+00:00","Level":"Warn","Message":"My message"}
                .EXAMPLE
                Write-Log -StartNew
                Starts a new logfile in the default location
                .EXAMPLE
                Write-Log -StartNew -Path c:\logs\new.log
                Starts a new logfile in the specified location
                .EXAMPLE
                Write-Log 'This is some information'
                Appends a new information line to the log.
                .EXAMPLE
                Write-Log -level warning 'This is a warning'
                Appends a new warning line to the log.
                .EXAMPLE
                Write-Log -level Error 'This is an Error'
                Appends a new Error line to the log.
                .EXAMPLE
                Write-Log -Exception $error[0]
                Appends a new Error line to the log with the message being the contents of the exception message.
                .EXAMPLE
                $error[0] | Write-Log
                Appends a new Error line to the log with the message being the contents of the exception message.
                .EXAMPLE
                'My log message' | Write-Log
                Appends a new Info line to the log with the message being the contents of the string.
                .EXAMPLE
                Write-Log 'My log message' -JSONFormat
                Appends a new Info line to the log with the message. The line will be in JSONFormat.
            #>

            [CmdletBinding(DefaultParametersetName = "LOG")]
            Param (
                [Parameter(Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    Position = 0,
                    ParameterSetName = 'LOG')]
                [ValidateNotNullOrEmpty()]
                [string]$Message,

                [Parameter(Mandatory = $false,
                    ValueFromPipelineByPropertyName = $true,
                    Position = 1,
                    ParameterSetName = 'LOG')]
                [ValidateSet('Error', 'Warn', 'Info', 'Debug')]
                [string]$Level = "Info",

                [Parameter(Mandatory = $false,
                    ValueFromPipelineByPropertyName = $true,
                    Position = 2)]
                [string]$Path = "$env:temp\FileSharePermissions.log",

                [Parameter(Mandatory = $false,
                    ValueFromPipelineByPropertyName = $true,
                    Position = 3)]
                [switch]$JSONFormat,

                [Parameter(Mandatory = $false,
                    ValueFromPipelineByPropertyName = $true,
                    Position = 4,
                    ParameterSetName = 'STARTNEW')]
                [switch]$StartNew,

                [Parameter(Mandatory = $true,
                    Position = 5,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    ParameterSetName = 'EXCEPTION')]
                [System.Management.Automation.ErrorRecord]$Exception
            )

            BEGIN {
                Set-StrictMode -version Latest #Enforces most strict best practice.
            }

            PROCESS {
                #Switch on parameter set
                switch ($PSCmdlet.ParameterSetName) {
                    LOG {
                        #Get human readable date
                        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

                        switch ( $Level ) {
                            'Error' { $LevelText = "ERROR:  "; break }
                            'Warn' { $LevelText = "WARNING:"; break }
                            'Info' { $LevelText = "INFO:   "; break }
                            'Debug' { $LevelText = "DEBUG:  "; break }
                        }

                        if ($JSONFormat) {
                            #Build an object so we can later convert it
                            $logObject = [PSCustomObject]@{
                                TimeStamp = Get-Date -Format o  #Get machine readable date
                                Level     = $Level
                                Message   = $Message
                            }
                            $logmessage = $logObject | ConvertTo-Json -Compress #Convert to a single line of JSON
                        }
                        else {
                            $logmessage = "$FormattedDate $LevelText $Message" #Build human readable line
                        }

                        $logmessage | Add-Content -Path $Path #write the line to a file
                        Write-Verbose $logmessage #Only verbose line in the function

                    } #LOG

                    EXCEPTION {
                        #Splat parameters
                        $WriteLogParams = @{
                            Level      = 'Error'
                            Message    = $Exception.Exception.Message
                            Path       = $Path
                            JSONFormat = $JSONFormat
                        }
                        Write-Log @WriteLogParams #Call itself to keep code clean
                        break

                    } #EXCEPTION

                    STARTNEW {
                        if (Test-Path $Path) {
                            Remove-Item $Path -Force
                        }
                        #Splat parameters
                        $WriteLogParams = @{
                            Level      = 'Info'
                            Message    = 'Starting Logfile'
                            Path       = $Path
                            JSONFormat = $JSONFormat
                        }
                        Write-Log @WriteLogParams
                        break

                    } #STARTNEW

                } #switch Parameter Set
            }

            END {
            }
        } #function
    }
    
    process {
        Write-Log -StartNew -Path $path
        Write-Log -Path $path "Obtaining file shares from computer: $ComputerName."
        Write-Verbose "Obtaining file shares from computer: $ComputerName."
        if([System.String]::IsNullOrEmpty($AdGroup)){
            $AdGroup = "Domain Admins"
        }
        $FileShare = get-wmiobject -Class win32_share -ComputerName $ComputerName | Where-Object {$_.Name -eq $Name}
        if ($null -eq $FileShare) {
            Write-Error "Could not find fileshare. Either Computername or file share name is invalid." -ErrorAction Stop
            Write-Log -path $path -Level Error "Could not find fileshare. Either Computername or file share name is invalid."
        }
        else {
            $FileShare_Location = $FileShare.Path
            Write-Verbose "Found fileshare: $Name located at $FileShare_Location"
            Write-Log -path $path "Found fileshare: $Name located at $FileShare_Location"
        }

        $Base_Folder = (Get-item -path $FileShare_Location).FullName

        # Remove ACL rules first
        (Get-Childitem -path $Base_Folder -recurse).FullName | ForEach-Object {
            $acl = Get-Acl $_
            $acl.Access | Where-Object {$acl.RemoveAccessRule($_)} | Out-Null
        }

        ## NTFS CREATOR OWNER
        Write-Verbose "Setting NTFS Permissions: CREATOR OWNER - Full Control (Apply onto: Subfolders and Files Only)"
        Write-Log -path $path "Setting NTFS Permissions: CREATOR OWNER - Full Control (Apply onto: Subfolders and Files Only)"
        $USERS = "CREATOR OWNER"
       
        $ACL = Get-acl $Base_Folder
        try {
            $Ar = New-Object system.Security.AccessControl.FileSystemAccessRule($USERS, "FullControl", "ContainerInherit, ObjectInherit", "InheritOnly", "Allow")
            $Acl.Setaccessrule($Ar)
        }
        catch {
            #Inherit doesn't work for files
            $Ar = New-Object system.Security.AccessControl.FileSystemAccessRule($USERS, "FullControl", "Allow")
            $Acl.Setaccessrule($Ar)
        }
        Set-Acl -path $Base_Folder $Acl
        #Remove-Variable $ACL

        Write-Verbose "Finished setting NTFS Permissions."
        Write-Log -path $path "Finished setting NTFS Permissions."
       
        ## System
        Write-Verbose "Setting System Settings: System - Full Control (Apply onto: This Folder, Subfolders and Files)"
        Write-Log -path $path "Setting System Settings: System - Full Control (Apply onto: This Folder, Subfolders and Files)"
    
        $ACL = get-acl $Base_Folder
        try {
            $Ar = New-Object system.Security.AccessControl.FileSystemAccessRule("System", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
            $Acl.SetAccessRule($Ar)
        }
        catch {
            #Inherit doesn't work for files
            $Ar = New-Object system.Security.AccessControl.FileSystemAccessRule("System", "FullControl", "Allow")
            $Acl.SetAccessRule($Ar)
        }
        Set-Acl -path $Base_Folder $ACL
        #Remove-Variable $ACL
        
        Write-Verbose "Finished Setting System Settings"
        Write-Log -path $path "Finished Setting System Settings"

        Write-Verbose "Setting Domain Admins Settings: Full Control (Apply onto: This Folder, Subfolders and Files)"
        write-log -path $path "Setting Domain Admins Settings: Full Control (Apply onto: This Folder, Subfolders and Files)"
        
        ## Domain Admins
        try {
            $DomainAdmins = Get-DomainAdminName
            foreach ($user in $DomainAdmins) {
                $ACL = get-acl $Base_Folder
                try {
                    #New-Object Security.AccessControl.ActiveDirectoryAccessRule <-- Might have to do this??
                    $Ar = New-Object system.Security.AccessControl.FileSystemAccessRule($user, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
                    $Acl.SetAccessRule($Ar)
                    }
                catch {
                    #Inherit doesn't work for files
                    $Ar = New-Object system.Security.AccessControl.FileSystemAccessRule($user, "FullControl", "Allow")
                    $Acl.SetAccessRule($Ar)
                }
                Set-Acl -path $Base_Folder
                
            }
        }
        catch {
            Write-Error $Error[0]
            Write-Log -Level Error -Path $path "Could not find active directory group: $AdGroup"
        }

        $Permissions = "CreateDirectories", "AppendData", "ListDirectory", "ReadData", "ReadAttributes", "Traverse", "Executefile"
        ## EVERYONE - APPLY TO THIS FOLDER ONLY CREATE FOLDER/APPEND DATA, LIST FOLDER/READ DATA, READ ATTRIBUTES, TRAVERSE FOLDER/EXECUTE FILE.
        Write-Verbose "Setting Everyone Settings(This folder only): (Create Folder/Append Data), (List Folder/Read Data), (Read Attributes), (Traverse Folder/Execute File). "
        write-log -path $path "Setting Everyone Settings(This folder only): (Create Folder/Append Data), (List Folder/Read Data), (Read Attributes), (Traverse Folder/Execute File). "
        
        $ACL = get-acl -path $Base_Folder
        #Remove-Variable $ACL

        try {
            $Ar = New-Object system.Security.AccessControl.FileSystemAccessRule("Everyone", $Permissions, "None", "None", "Allow")
            $Acl.SetAccessRule($Ar)
        }
        catch {
            #Inherit doesn't work for files
            $Ar = New-Object system.Security.AccessControl.FileSystemAccessRule("Everyone", $Permissions, "Allow")
            $Acl.SetAccessRule($Ar)
        }
        Set-Acl -path $Base_Folder $ACL
     
        Write-Verbose "Finished Setting permissions" 
        write-log -path $path "Finished Setting permissions"

        Write-Verbose "Setting Share Permissions: Everyone - Full Control"
        write-log -path $path "Setting Share Permissions: Everyone - Full Control"
        $command = "net share $name=$($fileshare.path) /grant:Everyone,FULL"
        invoke-expression $command
        Write-Verbose "Finished Setting Share Permissions"  
        write-log -path $path "Finished Setting Share Permissions"   
        Write-Log -Path $path "Finishing Set-FslFileShare"     
    }
    
    end { 
    }
}