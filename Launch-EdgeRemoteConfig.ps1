<#
.NOTES
With the help of            :   Jim Moyle @jimmoyle
How-To GUI From Jim Moyle   :   https://github.com/JimMoyle/GUIDemo

#>
$global:GUIversion = "0.9"
$global:IsModified = $false
<#
Global Variable ISMODIFIED controls the display of IP RANGES for connectors.
If an address has been modified but not yet pushed to the connector, then display
simple only - Simple is just IP addresses simple list because it's easier to
push to the connector by using Set-ReceiveConnector -RemoteIPRange $IpAddressesFromDataGrid
As we load again the receive connectors (Get-ReceiveConnectors button), ISMODIFIED is reset
to $False, enabling extended view of IP Ranges (CIBR which is xxx.xxx.xxx.xxx/xx type, range 
or Single, etc...)
#>

#========================================================
#region Functions definitions (NOT the WPF form events)
#========================================================

Function MessageBox ($Title = "Validation",$msg="Message not provided...",$Button = "YesNo",$Icon = "Question") {
    return [System.Windows.MessageBox]::Show($msg,$Title, $Button, $icon)
}

Function IsPSV3 {
    <#
    .DESCRIPTION
    Just printing Powershell version and returning "true" if powershell version
    is Powershell v3 or more recent, and "false" if it's version 2.
    .OUTPUTS
    Returns $true or $false
    .EXAMPLE
    IsPSVersionV3
    #>
    $PowerShellMajorVersion = $PSVersionTable.PSVersion.Major
    $msgPowershellMajorVersion = "You're running Powershell v$PowerShellMajorVersion"
    Write-Host $msgPowershellMajorVersion -BackgroundColor blue -ForegroundColor yellow
    If($PowerShellMajorVersion -le 2){
        Write-Host "Sorry, PowerShell v3 or more is required. Exiting."
        Return $false
        Exit
    } Else {
        Return $true
        }
}

Function Test-ExchTools(){
    <#
    .SYNOPSIS
    This small function will just check if you have Exchange tools installed or available on the
    current PowerShell session.
    
    .DESCRIPTION
    The presence of Exchange tools are checked by trying to execute "Get-ExBanner", one of the basic Exchange
    cmdlets that runs when the Exchange Management Shell is called.
    
    Just use Test-ExchTools in your script to make the script exit if not launched from an Exchange
    tools PowerShell session...
    
    .EXAMPLE
    Test-ExchTools
    => will exit the script/program si Exchange tools are not installed
    #>
        Try
        {
            Get-command Get-ExBanner -ErrorAction Stop
            $ExchInstalledStatus = $true
            $Message = "Exchange tools are present !"
            Write-Host $Message -ForegroundColor Blue -BackgroundColor Red
        }
        Catch [System.SystemException]
        {
            $ExchInstalledStatus = $false
            $Message = "Exchange Tools are not present ! This script/tool need these. Exiting..."
            Write-Host $Message -ForegroundColor red -BackgroundColor Blue
            Exit
        }
        Return $ExchInstalledStatus
    }

function Dump-ToHost {
    $AllIPS = $wpf.dataGridIPAllowed.ItemsSource
    $AllIPs | Get-Member
    $SelectedIPs = $wpf.dataGridIPAllowed.SelectedItems
    Write-Host $SelectedIPs
    $NbItemsSelected = $($SelectedIPs.count)
    Write-Host $AllIPs
    Write-Host $($AllIPS.count)
    #[System.Windows.messagebox]::Show("Where are $($SelectedIPs.count) IP addresses","IP addresses")
    Foreach ($IP in $SelectedIPs) {
        $ALLIPs = $ALLIPs | ? {$_.Expression -ne $($IP.Expression)}
    }
    $wpf.dataGridIPAllowed.ItemsSource = $AllIPS
    Write-Host "After removal of $NbItemsSelected IPs, we now have $($AllIPS.count) items"
    Write-Host $AllIPS

    Write-Host "Will set connector:"
    $wpf.datagridReceiveConnectors.SelectedItem.Name | out-host

}

Function Remove-IPs {
    $AllIPs = @{}
    $AllIPS = $wpf.dataGridIPAllowed.ItemsSource
    $SelectedIPs = $wpf.dataGridIPAllowed.SelectedItems
    Write-Host $SelectedIPs
    $NbItemsSelected = $($SelectedIPs.count)
    Write-Host $AllIPs
    Write-Host $($AllIPS.count)
    #[System.Windows.messagebox]::Show("Where are $($SelectedIPs.count) IP addresses","IP addresses")
    Foreach ($IP in $SelectedIPs) {
        [array]$ALLIPs = $ALLIPs | ? {$_.Expression -ne $($IP.Expression)}
    }

    "Count of IPs : $($ALLIPs.count)" | out-host

    If ($ALLIPS.Count -eq 1){
        $wpf.dataGridIPAllowed.ItemsSource = [array]$AllIPS
        $NewIPs = ("""") + $($AllIPs.Expression -join """,""") + ("""")
    } ElseIf ($ALLIPS.Count -eq 0) {
        $msg = "This will reset the Allowed IP to 0.0.0.0-255.255.255.255 if possible,`ndo you want to continue ?"
        $Decision = MessageBox -msg $msg
        "Décision = $Decision" | out-host
        If ($Decision -eq "Yes") {
            "Decision YES" | out-host
            #$ALLIPS = @{Expression="0.0.0.0-255.255.255.255"; RangeFormat=""; LowerBound=""; UpperBound=""; Netmask=""; CIDRLength=""; Size=""}
            $Array  = @{"IP Address"="0.0.0.0-255.255.255.255"}
            $ALLIPss = $Array
            $wpf.dataGridIPAllowed.ItemsSource = $ALLIPss
        } Else {
            "Decision = NO" | Out-Host
            #Do nothing and leave $NewIPS alone...
        }
    } Else {
        "More than 1 IPs..." | Out-Host
        $wpf.dataGridIPAllowed.ItemsSource = $AllIPS
        $NewIPs = ("""") + $($AllIPs.Expression -join """,""") + ("""")
    }
    
    Write-Host "After removal of $NbItemsSelected IPs, we now have $($AllIPS.count) items"

    Write-Host "Will set connector:"
    $ConnectorSelected = $wpf.datagridReceiveConnectors.SelectedItem.Name
    $ConnectorSelected = ("""") + $ConnectorSelected + ("""")
    $ConnectorSelected | out-host

    $command = "Get-ReceiveConnector $ConnectorSelected | Set-ReceiveConnector -RemoteIPRanges $NewIPs"
    $command | out-host
    Try{
        $CommandToInvoke = $Command + (" -ErrorAction Stop")
        #Invoke-Expression $commandToInvoke
    } Catch {
        $CommandGenerateError = $Command + (" -ErrorAction SilentlyContinue")
        #Invoke-Expression $commandGenerateError
        $msg = "Something went wrong when setting the Receive connector addresses.`nHere's the error message we got:`n`n$($Error[0])"
        MessageBox -msg $msg -title "Error in your attempt to remove IP address" -Icon "Stop" -Button "Ok"
    }
}

Function Split-ListColon {
    param(
        [string]$StringToSplit,
        [switch]$Noquotes
    )
    $TargetSplit = $StringToSplit.Split(',')
    $ListItems = ""
    If ($NoQuotes){
        For ($i = 0; $i -lt $TargetSplit.Count - 1; $i++) {$ListItems += $TargetSplit[$i].trim() + (", ")}
        $ListItems += $TargetSplit[$TargetSplit.Count - 1].trim()
    } Else {
        For ($i = 0; $i -lt $TargetSplit.Count - 1; $i++) {$ListItems += ("""") + $TargetSplit[$i].trim() + (""", ")}
        $ListItems += ("""") + $TargetSplit[$TargetSplit.Count - 1].trim() + ("""")
    }
    Return $ListItems
}

function ArrayToHash($a){
    $hash = @{}
    $index = 0
    $a | foreach { $hash.add($Index,$_);$index = $index + 1 }
    return $hash
}

function GetReceiveConnectors {
    $Global:ReceiveConnectors = Get-ReceiveConnector
    $ReceiveConnectorsList = $Global:ReceiveConnectors | Select name, @{Name = "Allowed IP Ranges";Expression={$_.RemoteIPRanges -Join ","}},fqdn

    $wpf.datagridReceiveConnectors.ItemsSource = $ReceiveConnectorsList
}

function GetReceiveConnectorRemoteIPRanges ([switch]$Simple) {
    If ($global:IsModified -eq $True) {
        $Simple = $True
    }
    #$wpf.dataGridIPAllowed.ItemsSource = $($wpf.datagridReceiveConnectors.SelectedItem."Allowed IP Ranges" -split ",")
    [array]$IPRangesCollection = @()
    If ($Simple) {
        $IPRangesCollection = $Global:ReceiveConnectors | ? {$_.Name -eq $wpf.datagridReceiveConnectors.SelectedItem.Name} | Select -ExpandProperty RemoteIPRanges | Select Expression
    } Else {
        $IPRangesCollection = $Global:ReceiveConnectors | ? {$_.Name -eq $wpf.datagridReceiveConnectors.SelectedItem.Name} | Select -ExpandProperty RemoteIPRanges | Select Expression,RangeFormat, LowerBound, UpperBound, NetMask, CIDRLength, Size
    }
    $wpf.dataGridIPAllowed.ItemsSource = $IPRangesCollection

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
        Title="Add or Remove IP Allow" Height="592.766" Width="917.596" ResizeMode="NoResize">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="507*"/>
            <ColumnDefinition Width="406*"/>
        </Grid.ColumnDefinitions>
        <Button x:Name="btnGetReceiveConnectors" Content="Get-ReceiveConnectors" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Width="474" Height="46" FontSize="20"/>
        <DataGrid x:Name="datagridReceiveConnectors" HorizontalAlignment="Left" Height="374" Margin="10,61,0,0" VerticalAlignment="Top" Width="474" SelectionMode="Single"/>
        <DataGrid x:Name="dataGridIPAllowed" HorizontalAlignment="Left" Height="162" Margin="1.5,61,0,0" VerticalAlignment="Top" Width="348" Grid.Column="1" AutoGenerateColumns="True" CanUserSortColumns="True"/>
        <Label Content="IP Allowed" HorizontalAlignment="Left" Margin="1.5,35,0,0" VerticalAlignment="Top" Height="26" Width="66" Grid.Column="1"/>
        <TextBox x:Name="txtIPAddresses" HorizontalAlignment="Left" Height="110" Margin="0,325,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="348" Grid.Column="1" IsEnabled="False"/>
        <Button x:Name="btnAddIPAddresses" Content="Add IP addresses" HorizontalAlignment="Left" Margin="2,440,0,0" VerticalAlignment="Top" Width="134" Height="30" Grid.Column="1" IsEnabled="False"/>
        <Button x:Name="btnRun" Content="Run" HorizontalAlignment="Left" Margin="10,450,0,0" VerticalAlignment="Top" Width="153" Height="41"/>
        <Button x:Name="btnCancel" Content="Cancel" HorizontalAlignment="Left" Margin="275,450,0,0" VerticalAlignment="Top" Width="153" Height="41"/>
        <StatusBar x:Name="statusBar" HorizontalAlignment="Left" Height="29" Margin="0,537,-0.5,-0.5" VerticalAlignment="Top" Width="913" Grid.ColumnSpan="2"/>
        <Button x:Name="btnRemoveAllowIPAddresses" Content="Remove selected IP Address(es)" HorizontalAlignment="Left" Margin="0,228,0,0" VerticalAlignment="Top" Width="193" Height="36" Grid.Column="1"/>
        <CheckBox x:Name="chkExtendedIPView" Content="Extended IP Info View" Grid.Column="1" HorizontalAlignment="Left" Margin="189,41,0,0" VerticalAlignment="Top"/>
        <TextBlock Grid.Column="1" HorizontalAlignment="Left" Margin="0,288,0,0" TextWrapping="Wrap" Text="Addresses to add (Comma separated - e.g. 125.3.10.15, 10.1.0.0/16, 212.12.0.0-212.12.255.255, 15.2.3.2):" VerticalAlignment="Top"/>
        <Button x:Name="btnApplyChanges" Content="Apply Changes" Grid.Column="1" HorizontalAlignment="Left" Margin="198,228,0,0" VerticalAlignment="Top" Width="152" Height="36" IsEnabled="False"/>
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

$wpf.btnRemoveAllowIPAddresses.add_click({
    $Global:IsModified = $true
    Remove-IPs
})

$wpf.btnDumpIPs.add_Click({
    Dump-ToHost
})

$wpf.btnAddIPAddresses.add_click({
    $Global:IsModified = $true
    $ArrayOfIPToAdd = Split-ListColon $wpf.txtIPAddresses.Text -Noquotes
    $SelectedConnectorFullObject = $Global:ReceiveConnectors | ? {$_.Name -eq $wpf.datagridReceiveConnectors.SelectedItem.Name}
    $SelectedConnectorRemoteIPRanges = $SelectedConnectorFullObject.RemoteIPRanges
    $SelectedConnectorRemoteIPRanges += $ArrayOfIPToAdd
    #Set-ReceiveConnector $($wpf.datagridReceiveConnectors.SelectedItem.Name) -RemoteIPRanges $SelectedConnectorRemoteIPRanges
    #GetReceiveConnectors
    $wpf.datagridReceiveConnectors.SelectedItem.Name = $SelectedConnectorFullObject.Name
    GetReceiveConnectorRemoteIPRanges
})

$wpf.btnGetReceiveConnectors.add_Click({
    $global:IsModified = $false
    $wpf.chkExtendedIPView.IsChecked = $false
    $wpf.chkExtendedIPView.IsEnabled = $false
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

$wpf.datagridReceiveConnectors.add_SelectionChanged({
    #write-host "Selection changed"
    If ($wpf.chkExtendedIPView.IsChecked -eq $true) {
        GetReceiveConnectorRemoteIPRanges
    } Else {
        GetReceiveConnectorRemoteIPRanges -Simple
    }
})

# $wpf.txtCSVComputersList.add_TextChanged({

# })

#End of Text Changed events
#endregion

#region Checkboxes checked and unchecked
$wpf.chkExtendedIPView.add_Checked({
    GetReceiveConnectorRemoteIPRanges
})
$wpf.chkExtendedIPView.add_UnChecked({
    GetReceiveConnectorRemoteIPRanges -Simple
})

# End of Checkboxes checked and unchecked
#endregion

#=======================================================
#End of Events from the WPF form
#endregion
#=======================================================

#Testing if at least PowerShell V3 is present
IsPSV3 | out-null
#Testing if Exchange Tools are loaded
Test-ExchTools | out-null

# Load the form:
# Older way >>>>> $wpf.EdgeIPAllow.ShowDialog() | Out-Null >>>> generates crash if run multiple times
# USing method from https://gist.github.com/altrive/6227237 to avoid crashing Powershell after we re-run the script after some inactivity time or if we run it several times consecutively...
$async = $wpf.EdgeIPAllow.Dispatcher.InvokeAsync({
    $wpf.EdgeIPAllow.ShowDialog() | Out-Null
})
$async.Wait() | Out-Null
