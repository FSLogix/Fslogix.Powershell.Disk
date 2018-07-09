function Copy-FslDiskContent {
    <#
        .SYNOPSIS
        Copies contents of a VHD to another VHD

        .PARAMETER FirstVHDPath
        The path to the first VHD we are copying from

        .PARAMETER FirstFilePath
        Optional file path within the first VHD

        .PARAMETER SecondVHDPath
        The path to the second VHD we are copying to

        .PARAMETER Secondfilepath
        Optional file path within second vhd

        .PARAMETER Overwrite
        Optional parameter to overwrite file contents if already existing in second VHD

        .EXAMPLE
        copy-fsldiskcontents -vhd1 C:\Users\danie\Documents\test1.vhd -Vhd2 C:\Users\Danie\Documents\test2.vhd -overwrite
        Will copy all the contents in test1.vhd into test2.vhd and overwrite any pre-existing files.

        .EXAMPLE
        copy-fsldiskcontents -vhd1 C:\Users\danie\Documents\test1.vhd -file scripts\public -Vhd2 C:\Users\Danie\Documents\test2.vhd -file2 scripts\test\public -overwrite
        Will copy all the contents in test1.vhd's path 'scripts\public' into the test2.vhd's path 'script\test\public'
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("VHD1")]
        [System.String]$FirstVHDPath,

        [Parameter(Position = 1)]
        [Alias("File")]
        [System.string]$FirstFilePath,

        [Parameter(Position = 2, Mandatory = $true)]
        [Alias("VHD2")]
        [System.String]$SecondVHDPath,

        [Parameter(Position = 3)]
        [Alias("File2")]
        [System.String]$SecondFilePath,

        [Parameter(Position = 4)]
        [Switch]$Overwrite
    )
    
    begin {
        ## Helper function to validate requirements
        set-strictmode -Version latest
        #If paths are invalid, get-driveletter script will handle it        
        $First_DL = get-driveletter -path $FirstVHDPath
        $Second_DL = get-driveletter -path $SecondVHDPath

        $FirstVHD = split-path $FirstVHDPath -Leaf
        $SecondVHD = split-path $SecondVHDPath -leaf

        $FirstFilePath = join-path($First_DL) ($FirstFilePath)
        $SecondFilePath = join-path($Second_DL) ($SecondFilePath)
    }
    
    process {
        if (-not(test-path -path $FirstFilePath)) {
            write-error "Could not find path: $firstfilepath" -ErrorAction Stop
        }
        if (-not(test-path -path $SecondFilePath)) {
            write-error "Could not find path: $SecondFilePath" -ErrorAction Stop
        }

        $Contents = get-childitem -path $FirstFilePath
        if ($Contents.Count -eq 0) {
            Write-Error "No Files found in $FirstFilePath" -ErrorAction Stop
        }

        $Contents | ForEach-Object { 

            if ($Overwrite) {
                Copy-Item -path $_.FullName -Destination $SecondFilePath -Recurse -Force
                Write-Verbose "Successfully copied and overwritten VHD:$firstVHD $($_.fullname) to VHD: $secondVHD $secondfilepath"
            }else{
                Copy-Item -path $_.FullName -Destination $SecondFilePath -Recurse -ErrorAction Stop
                Write-Verbose "Successfully Copied VHD:$firstVHD $($_.fullname) to VHD: $secondVHD $secondfilepath"
            }
           
        }#foreach

        $FirstVHDPath | dismount-FslDisk
        $SecondVHDPath | dismount-FslDisk
      
    }
    
    end {
    }
}