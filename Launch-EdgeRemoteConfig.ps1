# Interface WPF definition

@"

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



$ReceiveConnectorsList = Get-ReceiveConnector | Select name, RemoteIPRange,fqdn

$ReceiveConnectorsGrid01 = $ReceiveConnectorsList | Select Name, fqdn

$DataGrid01Source = $ReceiveConnectorsGrid01

$DataGridSource = $ReceiveConnectorsList.RemoteIPRange

