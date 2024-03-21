using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Construct the request URI
$resourceUri = "https://management.azure.com/"
$apiVersion = "2019-08-01"
$uri = "${env:IDENTITY_ENDPOINT}?resource=$resourceUri&api-version=$apiVersion"

try {
    # Attempt to retrieve the bearer token using Managed Identity
    $response = Invoke-RestMethod -Method Get -Headers @{
        "X-IDENTITY-HEADER" = $env:IDENTITY_HEADER
    } -Uri $uri

    $bearer_token = $response.access_token
    Write-Host "Bearer Token: $bearer_token"
} catch {
    Write-Host "Error retrieving access token: $_"
    # Setting bearer_token to a meaningful error message
    $bearer_token = "Failed to retrieve access token. Check function logs for more details."
}

# Assuming you want to return the bearer token or error message in the response
$body = @{
    message = $bearer_token
} | ConvertTo-Json

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
