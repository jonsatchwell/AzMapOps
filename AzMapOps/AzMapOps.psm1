$urlBase = 'https://atlas.microsoft.com'
$defaultApiVersion = "1.0"
$IS_PREVIEW = $false

function cleanUrl($url) {
    return $url.Replace("https://atlas.microsoft.com", "https://us.atlas.microsoft.com")
}

function newUrlWithQueryParams(
    [Parameter(Mandatory = $false)]
    [string]$baseURI = $urlBase,    
    [Parameter(Mandatory = $true)]
    [string]$queryParams
) {

    foreach ($item in $body.GetEnumerator()) {
        # Write-Output $item.value
        $query = [System.Web.HttpUtility]::ParseQueryString($uriBuilder.Query)
        $query[$item.key] = $item.Value

        $uriBuilder = [System.UriBuilder]::new($baseURI )
        $uriBuilder.Query = $query.ToString()
        $baseURI = $uriBuilder.ToString()
    }
    return $baseURI

}

function getWebResponseAzMaps
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
            [Parameter( Mandatory = $true)]
            [string]$subscriptionKey, 
            [Parameter(Mandatory = $true)]
            [string]$apiVersion, 
            [Parameter(Mandatory = $true)]
            [string]$uri, 
            [Parameter(Mandatory = $true)]
            [string]$method, 
            [Parameter(Mandatory = $false)]
            [string]$contentType, 
            [Parameter(Mandatory = $false)]
            [string]$filePath,
            [Parameter(Mandatory = $false)]
            [hashtable]$body
        )
    if ($IS_PREVIEW) { $uri = cleanUrl($uri) }
    
    if($method -eq "GET")
    {
        $body =@{}
        $body.Add("subscription-key", $subscriptionKey)
        if (-not($uri.Contains("api-version")))
        {
            $body.Add("api-version", $apiVersion)
        }
        # $uri = newUrlWithQueryParams $uri $body
        return Invoke-WebRequest -Body $body -Method $method -Uri $uri
    }
    elseif ($method -eq "POST") {
        if (-not($PSBoundParameters.ContainsKey('body'))) 
        {        
            $body = @{}
        }
        $body.Add("subscription-key", $subscriptionKey)
        $body.Add("api-version", $apiVersion)
        $uri = newUrlWithQueryParams $uri $body
        if ($PSBoundParameters.ContainsKey('contentType')) {
            return Invoke-WebRequest -Body $body -Method $method -Uri $uri -ContentType $contentType
        }
        else {
            return Invoke-WebRequest -Body $body -Method $method -Uri $uri
        }
    }
        
}

 function New-AzMapsDataUpload {
    
    <#
    .SYNOPSIS
    .EXAMPLE
    .EXAMPLE
    .INPUTS
    .INPUTS
    .OUTPUTS
        
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (   
        [Parameter( Mandatory = $true)]
        [string]$subscriptionKey,
        [Parameter(Mandatory = $false)]
        [string]$apiVersion = $defaultApiVersion,
        [Parameter(Mandatory = $true)]
        [string]$dataFormat,
        [Parameter(Mandatory = $true)]
        [string]$filePath,
        [Parameter(Mandatory = $false)]
        [switch]$isPreview
    )
    
    begin {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " begin")
        $script = "Using module AzMapOps"
        $script = [ScriptBlock]::Create($scriptBody)
        . $script
    }
    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")
        
        $IS_PREVIEW = $isPreview
        $contentType = "application/octet-stream"
        $uri = 'https://atlas.microsoft.com/mapData/upload'
        $body = @{}
        $body.Add("dataFormat", $dataFormat)
        $response = getWebResponseAzMaps -subscriptionKey $subscriptionKey -apiVersion $apiVersion -uri $uri -method "POST" -contentType $contentType -filePath $filePath -body $body
        return $response.Headers["Location"][0]
        
        # if ($response.Headers["Location"]) {
        # }
    }
    end {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " end")
    }

}

function New-AzMapsDataConversion {
    
    <#
    .SYNOPSIS
    .EXAMPLE
    .EXAMPLE
    .INPUTS
    .INPUTS
    .OUTPUTS
        
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (   
        [Parameter( Mandatory = $true)]
        [string]$subscriptionKey,
        [Parameter(Mandatory = $false)]
        [string]$apiVersion = $defaultApiVersion,
        [Parameter(Mandatory = $true)]
        [string]$udid,
        [Parameter(Mandatory = $true)]
        [string]$inputType,
        [Parameter(Mandatory = $false)]
        [switch]$isPreview
    )
    
    begin {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " begin")
        $script = "Using module AzMapOps"
        $script = [ScriptBlock]::Create($scriptBody)
        . $script
    }
    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")
        $IS_PREVIEW = $isPreview
        
        $uri = "$urlBase/conversion/convert"
        $body = @{}
        $body.Add("udid", $udid)
        $body.Add("inputType", $inputType)
        
        $response = getWebResponseAzMaps -subscriptionKey $subscriptionKey -apiVersion $apiVersion -uri $uri -method "POST" -body $body
        return $response.Headers["Location"][0]
    
    }
    end {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " end")
    }

}

function Get-AzMapOpsStatus {
    
    <#
    .SYNOPSIS
        Returns an 
    .EXAMPLE
       
    .INPUTS
         
    .OUTPUTS
        
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (   
        [Parameter( Mandatory = $true)]
        [string]$subscriptionKey,
        [Parameter(Mandatory = $false)]
        [string]$apiVersion = $defaultApiVersion,
        [Parameter(Mandatory = $false)]
        [string]$operation, 
        [Parameter(Mandatory = $false)]
        [string]$locationUrl,
        [Parameter( Mandatory = $false)]
        [string]$operationId,
        [Parameter(Mandatory = $false)]
        [switch]$isPreview
    )
    
    begin {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " begin")
        $script = "Using module AzMapOps"
        $script = [ScriptBlock]::Create($scriptBody)
        . $script
    }
    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")

        $IS_PREVIEW= $isPreview
        if ($PSBoundParameters.ContainsKey('locationUrl')) {
            $uri = $locationUrl
        }
        else {
            $uri = "$urlBase/$operation/operations/$operationId"
        }
        return getWebResponseAzMaps -subscriptionKey $subscriptionKey -apiVersion $apiVersion -uri $uri -method "GET"
    }
    end {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " end")
    }

}
function Get-AzMapOpsMetadata {
    
    <#
    .SYNOPSIS
        Returns an 
    .EXAMPLE
       
    .INPUTS
         
    .OUTPUTS
        
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (   
        [Parameter( Mandatory = $true)]
        [string]$subscriptionKey,
        [Parameter(Mandatory = $false)]
        [string]$apiVersion = $defaultApiVersion,
        [Parameter(Mandatory = $false)]
        [string]$operation, 
        [Parameter(Mandatory = $false)]
        [string]$uniqueId, 
        [Parameter(Mandatory = $false)]
        [string]$locationUrl,
        [Parameter(Mandatory = $false)]
        [switch]$isPreview
    )
    
    begin {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " begin")
        $script = "Using module AzMapOps"
        $script = [ScriptBlock]::Create($scriptBody)
        . $script
    }
    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")
        $IS_PREVIEW = $isPreview
        if ($PSBoundParameters.ContainsKey('locationUrl')) {
            $uri = $locationUrl
        }
        else {
            # Not implemented
            if($operation -eq 'conversion')
            {
                $uri = "$urlBase/$operation/$uniqueId"
            }
            elseif ($operation -eq 'mapData') {
                $uri = "$urlBase/$operation/metadata/$uniqueId"
            }
        }
        return getWebResponseAzMaps -subscriptionKey $subscriptionKey -apiVersion $apiVersion -uri $uri -method "GET"
    }
    end {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " end")
    }

}
function Get-AzMapOps {
    
    <#
    .SYNOPSIS
    .EXAMPLE
       
    .EXAMPLE
    .INPUTS
    .INPUTS
    .OUTPUTS
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (   
        [Parameter( Mandatory = $true)]
        [string]$subscriptionKey,
        [Parameter(Mandatory = $false)]
        [string]$apiVersion = $defaultApiVersion,
        [Parameter(Mandatory = $false)]
        [string]$operation,
        [Parameter(Mandatory = $false)]
        [switch]$isPreview
    )
    
    begin {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " begin")
        $script = "Using module AzMapOps"
        $script = [ScriptBlock]::Create($scriptBody)
        . $script
    }
    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")
        $IS_PREVIEW = $isPreview

        $uri = "$urlBase/$operation"

        $response = getWebResponseAzMaps -subscriptionKey $subscriptionKey -apiVersion $apiVersion -uri $uri -method "GET" 
        return $response.Content
    }
    end {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " end")
    }

}

# function Get-********* {
    
#     <#
#     .SYNOPSIS
#     .EXAMPLE
#     .EXAMPLE
#     .INPUTS
#     .INPUTS
#     .OUTPUTS
        
#     #>

#     [CmdletBinding(SupportsShouldProcess = $true)]
#     param (   
#         [Parameter( Mandatory = $true)]
#         [string]$subscriptionKey,
#         [Parameter(Mandatory = $false)]
#         [string]$apiVersion = $defaultApiVersion,
#         [Parameter(Mandatory = $false)]
#         [switch]$isPreview
#     )
    
#     begin {
#         Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " begin")
#         $script = "Using module AzMapOps"
#         $script = [ScriptBlock]::Create($scriptBody)
#         . $script
#     }
#     process {
#         Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")
       
#         return "something"
#     }
#     end {
#         Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " end")
#     }

# }