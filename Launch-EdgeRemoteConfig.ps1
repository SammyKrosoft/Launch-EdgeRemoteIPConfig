﻿<#
.NOTES
With the help of            :   Jim Moyle @jimmoyle
How-To GUI From Jim Moyle   :   https://github.com/JimMoyle/GUIDemo

#>
$global:GUIversion = "1.1"

#========================================================
#region Functions definitions (NOT the WPF form events)
#========================================================

function GetReceiveConnectors {
    $ReceiveConnectorsList = Get-ReceiveConnector | Select name, @{Name = "Allowed IP Ranges";Expression={$_.RemoteIPRanges -Join ","}},fqdn
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
        Title="Add or Remove IP Allow" Height="592.766" Width="917.596">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="507*"/>
            <ColumnDefinition Width="406*"/>
        </Grid.ColumnDefinitions>
        <Button x:Name="btnGetReceiveConnectors" Content="Get-ReceiveConnectors" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Width="474" Height="46" FontSize="20"/>
        <DataGrid x:Name="datagridReceiveConnectors" HorizontalAlignment="Left" Height="374" Margin="10,61,0,0" VerticalAlignment="Top" Width="474" SelectionMode="Single"/>
        <DataGrid x:Name="dataGridIPAllowed" HorizontalAlignment="Left" Height="162" Margin="1.5,61,0,0" VerticalAlignment="Top" Width="348" Grid.Column="1"/>
        <Label Content="IP Allowed" HorizontalAlignment="Left" Margin="1.5,35,0,0" VerticalAlignment="Top" Height="26" Width="66" Grid.Column="1"/>
        <TextBox x:Name="txtIPAddresses" HorizontalAlignment="Left" Height="125" Margin="1.5,285,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="348" Grid.Column="1"/>
        <Button x:Name="btnRemoveIPAddresses" Content="Remove" HorizontalAlignment="Left" Margin="1.5,228,0,0" VerticalAlignment="Top" Width="74" Height="20" Grid.Column="1"/>
        <Button x:Name="btnAddIPAddresses" Content="Add" HorizontalAlignment="Left" Margin="1.5,415,0,0" VerticalAlignment="Top" Width="74" Height="20" Grid.Column="1"/>
        <Button x:Name="btnRun" Content="Run" HorizontalAlignment="Left" Margin="10,450,0,0" VerticalAlignment="Top" Width="153" Height="41"/>
        <Button x:Name="btnCancel" Content="Cancel" HorizontalAlignment="Left" Margin="275,450,0,0" VerticalAlignment="Top" Width="153" Height="41"/>
        <StatusBar x:Name="statusBar" HorizontalAlignment="Left" Height="29" Margin="0,537,-0.5,-0.5" VerticalAlignment="Top" Width="913" Grid.ColumnSpan="2"/>
    </Grid>
</Window>

"@

$inputXMLClean = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace 'x:Class=".*?"','' -replace 'd:DesignHeight="\d*?"','' -replace 'd:DesignWidth="\d*?"',''
[xml]$xaml = $inputXMLClean
$reader = New-Object System.Xml.XmlNodeReader $xaml
$tempform = [Windows.Markup.XamlReader]::Load($reader)
$namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
$namedNodes | ForEach-Object {$wpf.Add($_.Name, $tempform.FindName($_.Name))}



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
    $wpf.EdgeIPAllow.Title += (" - v") + ($global:GUIversion)
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
# $wpf.txtCSVComputersList.add_TextChanged({

# })

#End of Text Changed events
#endregion

#region Checkboxes checked and unchecked
# $wpf.chkAppLog.add_Checked({

# })
# $wpf.chkAppLog.add_UnChecked({

# })

# End of Checkboxes checked and unchecked
#endregion

#=======================================================
#End of Events from the WPF form
#endregion
#=======================================================



# Load the form:
$wpf.EdgeIPAllow.ShowDialog() | Out-Null