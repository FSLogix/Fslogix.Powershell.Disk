function Get-FslDuplicates {
    <#
        .SYNOPSIS
        Returns any duplicate files within disk.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, 
            Mandatory = $true, 
            ValueFromPipeline = $true,
            HelpMessage = 'Path to specified VHD or directory containing VHDs' )]
        [System.String]$vhdPath,

        [Parameter(Position = 1, 
            Mandatory = $false, 
            ValueFromPipeline = $true,
            HelpMessage = 'Specific directory search within a VHD')]
        
        [System.String]$Path,

        [Parameter(Position = 2, Mandatory = $true)]
        [System.String]$Csvpath,

        [Parameter(Position = 3, Mandatory = $false, ValueFromPipeline = $true)]
        [Alias("Confirm")]
        [ValidateSet("True", "False")]
        [System.String]$Remove_Duplicates

    )
    
    begin {
        set-strictmode -Version latest
        $Remove = $false
        $HashArray = new-object System.Collections.ArrayList
    }
    
    process {

        ## Validate inputs ##
        if ($Remove_Duplicates -eq "true") {
            $Remove -eq $true
        }

        if ($path -ne "") {
            $check_If_Directory = [System.IO.Path]::GetExtension($path)
            if ($check_If_Directory -ne "") {
                Write-Error "$Path must be a directory."
                exit
            }
        }

        $CheckCsv = [System.IO.Path]::GetExtension($csvpath)
        if($CheckCsv -ne ".csv"){
            write-error "$Csvpath must have .csv extension"
            exit 
        }else{
            remove-item -path $Csvpath -Force -ErrorAction SilentlyContinue
            Add-Content -Path $Csvpath 'Original,Duplicate'
        }
        
        ## Get VHDs ##
        Write-Verbose "Retrieving VHD(s)"
        $VHDs = get-fslvhd -path $vhdpath
        if ($null -eq $VHDs) {
            Write-Warning "Could not find VHDs in $vhdpath"
            exit
        }
        
        ## Search Duplicates ##
        foreach ($vhd in $VHDs) {

            $name = split-path -path $vhd.path -leaf

            $DriveLetter = get-Driveletter -path $vhd.path
            $Path_To_Search = join-path ($DriveLetter)($path)
            Write-Verbose "Searching for Duplicates in $($vhd.path)"

            if (-not(test-path -path $Path_To_Search)) {
                Write-Warning "$name : Could not find path: $Path_To_Search"
            }

            ## Find Duplicate Algorithm ##
            ## Is there a faster comparing algorithm? ##
            $files = get-childitem -path $Path_To_Search -Recurse | Sort-Object -Property LastWriteTime -Descending
            foreach ($file in $files) {

                $currentfile = 0
                try {
                    ## Get File's hash value, skipping if folder ##
                    $get_FileHash = Get-FileHash -path $file.fullname
                    $FileHash = $get_FileHash.hash
                    Write-Verbose "Obtained $file's hash value."
                }
                catch [System.Management.Automation.PropertyNotFoundException] {
                    Write-Warning "'$file' is not a file... Skipping."
                    continue
                }

                ## Compare Current hash to rest of childitem's hash values ##
                foreach ($cmpFile in $files | where-object {$_.Name -ne $file.Name}) {
                    $get_FileHash = get-filehash -path $cmpFile.fullname
                    $cmpHash = $get_FileHash.hash

                    ## Avoid comparing duplicates we've already checked ##
                    if($HashArray.Contains($cmpHash)){
                        break;
                    }

                    if($FileHash -eq $cmpHash){
                        Write-Verbose "Duplicate found!"
                        if($currentfile -eq 0){
                            $currentfile++
                            $output = $file.name + ',' + $cmpFile.fullname
                        }else{
                            $output = ',' + $cmpFile.FullName
                        }
                        Add-Content -path $Csvpath $output
                    }
                }

                ## We found all duplicates of this hash. No more comparisons ##
                $HashArray.Add($FileHash) > $null
            }
            dismount-FslDisk -path $vhd.path
        }
    }
    
    end {
    }
}
