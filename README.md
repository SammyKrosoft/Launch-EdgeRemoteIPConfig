# Launch-EdgeRemoteIPConfig

This is a Graphical User Interface to manage Exchange 2013/2016's Remote IP ranges. The purpose is to generate the corresponding PowerShell comamand, and optionally the admin can copy/paste it to another Exchange Management Shell or for documentation purposes, or just run that generated command.

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


