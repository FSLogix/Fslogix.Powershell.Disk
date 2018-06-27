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

        $HashArray = @{}
        $HashInfo = @{}
        $Duplicates = @{}
        $HashCounter = 1
        $DupCounter = 1
        $csvLineNumber = 0

        $name = split-path -path $path -leaf

        $DriveLetter = get-Driveletter -path $path
        $Path_To_Search = join-path ($DriveLetter)($folderpath)
        Write-Verbose "Searching for Duplicates in $path"

        if (-not(test-path -path $Path_To_Search)) {
            Write-Warning "$name : Could not find path: $Path_To_Search"
        }

        ## Find Duplicate Algorithm ##
        ## Is there a faster comparing algorithm than current O(n) Hashtable compare? ##
        $files = get-childitem -path $Path_To_Search -Recurse | Sort-Object -Property LastWriteTime -Descending 
        foreach($file in $files){

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

            ## Hashtable will have unique values of hashcode ##
            if ($HashArray.ContainsValue($FileHash)) {
                Write-Verbose "Duplicate found!"
                $Duplicates.add($DupCounter++, $file.fullname)
                if ($csvLineNumber++ -eq 0) {
                    $file | Add-Member @{VHD = $name}

                }else {
                    $file | Add-Member @{VHD = ' '}
                }
                
                $file | Add-Member @{Original = $HashInfo[$FileHash]}
                $file | Add-Member @{Duplicate = $file.fullname}
               
                $fileProperties =  $file | Select-Object -Property VHD, Original, Duplicate
                $fileProperties | export-Csv -path $Csvpath -Delimiter "`t" -NoTypeInformation -Append -Force

            } else {
                ## Add first occuring hash code of a file ##
                $HashInfo.add($FileHash, $file.name) # Unique Hash Code identifer
                $HashArray.Add($HashCounter++,$FileHash) 
            }
        }
    
        ## User wants to delete duplicate files ##
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
        
        ## Finish process ##
        dismount-FslDisk -path $path
    }#process
    
    end {
    }
}
