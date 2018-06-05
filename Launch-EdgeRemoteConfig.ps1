<#
.NOTES
With the help of            :   Jim Moyle @jimmoyle
How-To GUI From Jim Moyle   :   https://github.com/JimMoyle/GUIDemo

#>
$global:GUIversion = "1.1"

#========================================================
#region Functions definitions (NOT the WPF form events)
#========================================================

function GetReceiveConnectors {
    $ReceiveConnectorsList = Get-ReceiveConnector | Select name, RemoteIPRange,fqdn
    $wpf.datagridReceiveConnectors.ItemsSource = $ReceiveConnectorsList 
}

function GetReceiveConnectorRemoteIPRanges {
    $wpf.datagridReceiveConnectors.SelectedItem.Content.RemoteIPRange
    #$DataGrid02Source = $SelectedReceiveConnectorFromDataGrid01.RemoteIPRange
    # If (RemoteIPRange -eq "WithLoHi") {Display it a certain way}
    # If (RemoteIPRange -eq "Collection") {$DataGrid02Source = $SelectedReceiveConnectorFromDataGrid01.RemoteIPRange}


}

#========================================================
# END of Functions definitions (NOT the WPF form events)
#endregion
#========================================================

#========================================================
#region WPF form definition and load controls
#========================================================

# Load a WPF GUI from a XAML file build with Visual Studio
Add-Type -AssemblyName presentationframework, presentationcore
$wpf = @{ }
# NOTE: Either load from a XAML file or paste the XAML file content in a "Here String"
#$inputXML = Get-Content -Path ".\WPFGUIinTenLines\MainWindow.xaml"
$inputXML = @"

<Window x:Name="EdgeIPAllow" x:Class="Add_Remove_IP_EDGE2016.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Add_Remove_IP_EDGE2016"
        mc:Ignorable="d"
        Title="Add or Remove IP Allow" Height="592.766" Width="800">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="147*"/>
            <ColumnDefinition Width="118*"/>
        </Grid.ColumnDefinitions>
        <Button x:Name="btnGetReceiveConnectors" Content="Get-ReceiveConnectors" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Width="153"/>
        <DataGrid x:Name="datagridReceiveConnectors" HorizontalAlignment="Left" Height="374" Margin="10,35,0,0" VerticalAlignment="Top" Width="418" SelectionMode="Single"/>
        <DataGrid x:Name="dataGridIPAllowed" HorizontalAlignment="Left" Height="139" Margin="433,61,0,0" VerticalAlignment="Top" Width="349" Grid.ColumnSpan="2"/>
        <Label Content="IP Allowed" HorizontalAlignment="Left" Margin="433,35,0,0" VerticalAlignment="Top" Grid.ColumnSpan="2"/>
        <TextBox x:Name="txtIPAddresses" HorizontalAlignment="Left" Height="77" Margin="433,285,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="349" Grid.ColumnSpan="2"/>
        <Button x:Name="btnRemoveIPAddresses" Content="Remove" HorizontalAlignment="Left" Margin="433,205,0,0" VerticalAlignment="Top" Width="75" Grid.ColumnSpan="2"/>
        <Button x:Name="btnAddIPAddresses" Content="Add" HorizontalAlignment="Left" Margin="433,367,0,0" VerticalAlignment="Top" Width="75" Grid.ColumnSpan="2"/>
        <Button x:Name="btnRun" Content="Run" HorizontalAlignment="Left" Margin="10,434,0,0" VerticalAlignment="Top" Width="153" Height="41"/>
        <Button x:Name="btnCancel" Content="Cancel" HorizontalAlignment="Left" Margin="275,434,0,0" VerticalAlignment="Top" Width="153" Height="41"/>
        <StatusBar x:Name="statusBar" HorizontalAlignment="Left" Height="29" Margin="0,537,0,-0.5" VerticalAlignment="Top" Width="795" Grid.ColumnSpan="2"/>

    </Grid>
</Window>

"@

$inputXMLClean = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace 'x:Class=".*?"','' -replace 'd:DesignHeight="\d*?"','' -replace 'd:DesignWidth="\d*?"',''
[xml]$xaml = $inputXMLClean
$reader = New-Object System.Xml.XmlNodeReader $xaml
$tempform = [Windows.Markup.XamlReader]::Load($reader)
$namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
$namedNodes | ForEach-Object {$wpf.Add($_.Name, $tempform.FindName($_.Name))}

# Load the form:
$wpf.GrabEventLogs.ShowDialog() | Out-Null

#========================================================
# END of WPF form definition and load controls
#endregion
#========================================================

#========================================================
#region WPF EVENTS definition
#========================================================

#region Load, Draw (render) and closing form events
#Things to load when the WPF form is loaded aka in memory
$wpf.EdgeIPAllow.Add_Loaded({
    $wpf.EdgeIPAllow.Title += (" -") + ($global:GUIversion)
})
#Things to load when the WPF form is rendered aka drawn on screen
$wpf.EdgeIPAllow.Add_ContentRendered({
})
$wpf.EdgeIPAllow.add_Closing({
    $msg = "bye bye !"
    Write-host $msg
})
# End of load, draw and closing form events
#endregion

#region Buttons
$wpf.btnGetReceiveConnectors.add_Click({
    $msg = "Getting receive connectors..."
    Write-Host $msg
    GetReceiveConnectors
})

$wpf.btnCancel.add_Click({
    $msg = "Exiting..."
    Write-Host $msg
    $wpf.EdgeIPAllow.Close()
})
# End of Buttons region
#endregion

#region Text Changed events
$wpf.txtCSVComputersList.add_TextChanged({

})

#End of Text Changed events
#endregion

#region Checkboxes checked and unchecked
$wpf.chkAppLog.add_Checked({

})
$wpf.chkAppLog.add_UnChecked({

})

# End of Checkboxes checked and unchecked
#endregion

#=======================================================
#End of Events from the WPF form
#endregion
#=======================================================



