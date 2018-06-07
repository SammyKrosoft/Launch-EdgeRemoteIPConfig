# Launch-EdgeRemoteIPConfig

This is a Graphical User Interface to manage Exchange 2013/2016's Remote IP ranges. The purpose is to give you a graphical view of the list of IP addresses that are allowed on a selected Receive Connector.

At this stage (v.0.5), you can only graphically view the list of IP addresses that are currently Allowed on each Receive Connector, and you can activate an "extended view" to view the properties of each IP address entry (whether it's a Single IP Address, or a CIDR expression - as in 10.0.0.0/24, or an IP range as in 0.0.0.0-255.255.255.255 like in the default receive connectors...)

You can also select all the IP addresses, and copy these somewhere for documentation purposes for example...

# Current appearance (as of v0.5b)

![Fig1](/Screenshots/EdgeRemoteIPConfig-Fig1.png)

## Functionalities

List all the Receive Connectors, list the Remote IPs for each selected Receive Connectors, remove or add remote IP addresses for a selected Receive Connector.

## High Level Principles

### Initiating the list of receive connectors

$ReceiveConnectorsList = Get-ReceiveConnector | Select name, fqdn

Then feeding a selectable data grid table on the interface to enable the admin to choose which Receive Connector to set

### When user selects one of the items in the data grid, populate another data grid table with Remote IP ranges

Then trigger a (Get-ReceiveConnector $SelectedReceiveConnector.Name).RemoteIPRange to feed the second Data Grid.

### Notes about the Data Grids

First data grid (holding receive connectors) is single-select only
Second data grid (holding Remote IP Addresses) is multi-select (we want to be able to remove several IP addresses at a time)


