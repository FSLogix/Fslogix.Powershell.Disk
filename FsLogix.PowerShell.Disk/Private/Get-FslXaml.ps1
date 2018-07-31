function Get-FslXaml {
    <#
        .SYNOPSIS
        Retrieves the .xaml file and loads the framework.
        Outputs the xaml contents
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,
            Mandatory = $true, 
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true)]
        [System.String]$XamlPath
    )
    
    begin {
        set-strictmode -Version latest
    }
    
    process {

        try {
            # Add the frameworks to create wpf gui
            Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase, system.windows.forms
        }
        catch {
            Write-Error "Failed to load Windows Presentation Framework assemblies." -ErrorAction Stop
        }
        
        if (-not(test-path $XamlPath)) {
            Write-Error "Could not find XAML document." -ErrorAction Stop
        }


        #############################################
        # Code from Jim Moyle @ FsLogix             #
        # Website: https://github.com/JimMoyle      #
        #############################################
        $WPF = @{}
        $InputXaml = get-content -path $XamlPath
        #clean up xml there is syntax which Visual Studio 2015 creates which PoSH can't understand
        $inputXMLClean = $inputXaml -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace 'x:Class=".*?"', '' -replace 'd:DesignHeight="\d*?"', '' -replace 'd:DesignWidth="\d*?"', ''
        [Xml]$xaml = $inputXMLClean
        $reader = new-object System.xml.xmlNodeReader $xaml
        $tempform = [windows.markup.xamlReader]::load($reader)
        $namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
        
        $namedNodes | ForEach-Object {
            $wpf.Add($_.Name, $tempform.FindName($_.Name))
        }
        $WPF.ProcmonGui.ShowDialog() | out-null
        Write-Output $WPF
    }
    
    end {
    }
}# Get-FslXaml