<#
.NOTES
With the help of            :   Jim Moyle @jimmoyle
How-To GUI From Jim Moyle   :   https://github.com/JimMoyle/GUIDemo

#>
$global:GUIversion = "1.1"

# Interface WPF definition


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
        Title="Add or Remove IP Allow" Height="450" Width="800">
    <Grid>
        <Button x:Name="btnGetReceiveConnectors" Content="Get-ReceiveConnectors" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Width="153"/>
        <DataGrid x:Name="datagridReceiveConnectors" HorizontalAlignment="Left" Height="374" Margin="10,35,0,0" VerticalAlignment="Top" Width="418" SelectionMode="Single"/>
        <DataGrid x:Name="dataGridIPAllowed" HorizontalAlignment="Left" Height="139" Margin="433,61,0,0" VerticalAlignment="Top" Width="349"/>
        <Label Content="IP Allowed" HorizontalAlignment="Left" Margin="433,35,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="txtIPAddresses" HorizontalAlignment="Left" Height="77" Margin="433,285,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="349"/>
        <Button x:Name="btnRemoveIPAddresses" Content="Remove" HorizontalAlignment="Left" Margin="433,205,0,0" VerticalAlignment="Top" Width="75"/>
        <Button x:Name="btnAddIPAddresses" Content="Add" HorizontalAlignment="Left" Margin="433,367,0,0" VerticalAlignment="Top" Width="75"/>

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
$wpf.EventCollectWindow.Add_Loaded({
    $wpf.EdgeIPAllow.Title += (" -") + ($global:GUIversion)
})
#Things to load when the WPF form is rendered aka drawn on screen
$wpf.EventCollectWindow.Add_ContentRendered({
    Update-cmd
})
$wpf.EventCollectWindow.add_Closing({
    $msg = "bye bye !"
    Write-host $msg
})
# End of load, draw and closing form events
#endregion
#region Buttons
$wpf.btnRun.add_Click({
    $msg = "Running the command"
    WritNSay $msg
    Invoke-expression $wpf.txtCommand.text
})

$wpf.btnCancel.add_Click({
    $msg = "Exiting..."
    WritNSay $msg
    $wpf.EventCollectWindow.Close()
})
# End of Buttons region
#endregion

#region Speech management region
$wpf.chkSpeech.add_Checked({
    $wpf.lstBoxLanguage.Isenabled = $true
    If ($($wpf.lstBoxLanguage.SelectedItem.content) -eq "Francais") {
        $msg = "Narrateur activé - merci de m'enlever mon baillon !"
    } Else {
        $msg = "Narrator activated - thanks for unmuting me !"
    }
    WritNsay $msg
})

$wpf.chkSpeech.add_UnChecked({
    $wpf.lstBoxLanguage.Isenabled = $false
})

$wpf.lstBoxLanguage.add_SelectionChanged({
    $msg = "Language = $($wpf.lstBoxLanguage.SelectedItem.content)"
    If ($($wpf.lstBoxLanguage.SelectedItem.content) -eq "Francais") {
        $msg = "Langue Francaise sélectionnée !"
    } Else {
        $msg = "English Language selected !"
    }
    WritNsay $msg})

# End of speech management region
#endregion

#region Load, Draw (render) and closing form events
#Things to load when the WPF form is loaded aka in memory
$wpf.EventCollectWindow.Add_Loaded({
    $wpf.lblGUIVer.content += $global:GUIversion
    $wpf.lblFUNCVer.content += (" ") + (Get-EventsFromEventLogs -CheckVersion)
})
#Things to load when the WPF form is rendered aka drawn on screen
$wpf.EventCollectWindow.Add_ContentRendered({
    Update-cmd
})
$wpf.EventCollectWindow.add_Closing({
    $msg = "bye bye !"
    write-Host $msg
})
# End of load, draw and closing form events
#endregion

#region Text Changed events
$wpf.txtCSVComputersList.add_TextChanged({
    Update-cmd
})

#End of Text Changed events
#endregion

#region Clicked on Checkboxes events
$wpf.chkAppLog.add_Click({
    Update-cmd
})

# End of Clicked on Checkboxes events
#endregion

#=======================================================
#End of Events from the WPF form
#endregion
#=======================================================


$ReceiveConnectorsList = Get-ReceiveConnector | Select name, RemoteIPRange,fqdn

$ReceiveConnectorsGrid01 = $ReceiveConnectorsList | Select Name, fqdn
$DataGrid01Source = $ReceiveConnectorsGrid01


$DataGrid02Source = $SelectedReceiveConnectorFromDataGrid01.RemoteIPRange
If (RemoteIPRange -eq "WithLoHi") {Display it a certain way}
If (RemoteIPRange -eq "Collection") {$DataGrid02Source = $SelectedReceiveConnectorFromDataGrid01.RemoteIPRange}

