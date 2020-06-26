# AzMapOps
Powershell module for working with the Azure Maps API. 

Designed after working through this Creator tutorial:
https://docs.microsoft.com/en-us/azure/azure-maps/tutorial-creator-indoor-maps

How to get started:
1. clone the repo
2. create a subscripiton json file to store your subscription key- like this: {"subscriptionKey":"AZMAPS_SUBSCRIPTIONKEY"}.  Or just put your subscriptionkey info to the $mapsSubscriptionKey variable in the test-AzMapsOps.ps1 file.
3. GetPowershell 7
4. Step through the test-AzMapsOps.ps1 file to upload, check status, list data, convert mapData upload to a dataset.  

Download the sample drawing package from here:
https://github.com/Azure-Samples/am-creator-indoor-data-examples

TODO: tileset create, WFS query
