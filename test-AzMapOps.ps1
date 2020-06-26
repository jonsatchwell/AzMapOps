test-modulemanifest .\AzMapOps\AzMapOps.psd1
Import-Module .\AzMapOps\AzMapOps.psd1 -Force

# Variables for all tests
$json = Get-Content '..\azmaps-subscription-info.json' | Out-String | ConvertFrom-Json
$mapsSubscriptionKey = $json.subscriptionKey 
Write-Host $mapsSubscriptionKey
$mapsApiVersion = '1.0'

# Test List datasets - returns all the data you have stored as az maps datasets
$response = Get-AzMapOps -subscriptionKey $mapsSubscriptionKey -operation 'dataset' -isPreview -Verbose
$json = $response
Write-Output $json
$testtable = $json | ConvertFrom-Json  | select -expand datasets | select datasetId, created
Write-Output $testtable

# Test List mapData - returns list of all the mapData uploaded to az maps
$response = Get-AzMapOps -subscriptionKey $mapsSubscriptionKey -operation 'mapData' -isPreview -Verbose
$json = $response
Write-Output $json
$testtable = $json | ConvertFrom-Json  | select -expand mapDataList | select udid, created, uploadStatus, location
Write-Output $testtable

# Test Data Upload dwg in zip - POST
$FilePath = '..\am-creator-indoor-data-examples\Sample - Contoso Drawing Package.zip'
$dataFormat ='zip'
$location = New-AzMapsDataUpload -subscriptionKey $mapsSubscriptionKey -dataFormat $dataFormat -filePath $FilePath -isPreview -Verbose
Write-Host $location

# Test Data Upload status
$response = Get-AzMapOpsStatus -subscriptionKey $mapsSubscriptionKey -apiVersion $mapsApiVersion -operation 'mapData' -locationUrl $location -isPreview -Verbose
Write-Host $response
# {"status":"Succeeded","resourceLocation":"https://atlas.microsoft.com/mapData/metadata/21d9810e-c77b-9418-08dd-f0b28c8867a0?api-version=1.0"}
$json = $response | ConvertFrom-Json
if ($json.status -eq "Succeeded") { 
    $resourceLocation = $json.resourceLocation 
    write-host $resourceLocation

    $response = Get-AzMapOpsMetadata -subscriptionKey $mapsSubscriptionKey -apiVersion $mapsApiVersion -locationUrl $resourceLocation -isPreview -Verbose
    Write-Host $response
    $jsonmetadata = $response | ConvertFrom-Json
    $udid = $jsonmetadata.udid
    Write-Host $udid

} 

# Test Convert map data
$inputType ='DWG'
$location = New-AzMapsDataConversion -subscriptionKey $mapsSubscriptionKey -inputType $inputType -udid $udid -isPreview -Verbose
Write-Host $location

# Test Get AzMapOpsStatus CONVERSION
$response = Get-AzMapOpsStatus -subscriptionKey $mapsSubscriptionKey -operation 'conversion' -apiVersion $mapsApiVersion -locationUrl $location -isPreview -Verbose
Write-Host $response
# { "operationId":"0ebf9959-76fd-43a4-8f8d-da711f8a2992", "created":"2020-06-26T14:02:44.5930014+00:00", "status":"Succeeded", "resourceLocation":"https://atlas.microsoft.com/conversion/86a70a09-1b0e-f3b2-00ae-56376d8975c1?api-version=1.0", "properties": {}}
$json = $response | ConvertFrom-Json
if ($json.status -eq "Succeeded") { 
    $resourceLocation = $json.resourceLocation 
    write-host $resourceLocation

    $response = Get-AzMapOpsMetadata -subscriptionKey $mapsSubscriptionKey -apiVersion $mapsApiVersion -locationUrl $resourceLocation -isPreview -Verbose
    Write-Host $response
    $jsonmetadata = $response | ConvertFrom-Json
    $conversionId = $jsonmetadata.conversionId
    Write-Host $conversionId
} 
