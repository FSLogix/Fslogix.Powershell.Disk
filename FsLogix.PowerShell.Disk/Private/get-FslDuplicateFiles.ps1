function get-FslDuplicateFiles {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$path,

        [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true)]
        [System.String]$Folderpath,

        [Parameter(Position = 2, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]$Csvpath,

        [Parameter(Position = 3, Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("True", "False")]
        [System.String]$Remove
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {

        $HashArray = new-object System.Collections.ArrayList   
        $Duplicates = new-object System.Collections.ArrayList     
        $name = split-path -path $path -leaf

        $DriveLetter = get-Driveletter -path $path
        $Path_To_Search = join-path ($DriveLetter)($folderpath)
        Write-Verbose "Searching for Duplicates in $path"

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
                    
                try {
                    $get_FileHash = get-filehash -path $cmpFile.fullname
                    $cmpHash = $get_FileHash.hash
                }
                catch [System.Management.Automation.PropertyNotFoundException] {
                    Write-Warning "'$cmpfile' is not a file... Skipping."
                    continue
                }   

                ## Avoid comparing duplicates we've already checked ##
                if ($HashArray.Contains($cmpHash)) {
                    Write-Verbose "Already found $cmpfile's duplicates"
                    break;
                }

                if ($FileHash -eq $cmpHash) {
                    Write-Verbose "Duplicate found!"
                    if ($currentfile -eq 0) {
                        $currentfile++
                        $output = $name + ',' + $file.name + ',' + $cmpFile.fullname
                    }
                    else {
                        $output = ',' + ',' + $cmpFile.FullName
                    }
                    $Duplicates.add($cmpFile.fullname) > $null
                    Add-Content -path $Csvpath $output
                }
            }

            ## We found all duplicates of this hash. No more comparisons ##
            $HashArray.Add($FileHash) > $null
        }#foreach
        if($remove -eq "true"){
            foreach($fp in $Duplicates){
                $filename = split-path -path $fp -leaf
                try{
                    Write-Verbose "Removing duplicate file: $filename"
                    remove-item -path $fp -Force
                }catch{
                    Write-Error $Error[0]
                }
            }
        }
        dismount-FslDisk -path $path
    }#process
    
    end {
    }
}