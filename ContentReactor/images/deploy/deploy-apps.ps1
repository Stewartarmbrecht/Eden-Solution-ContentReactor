param([String] $systemName, [String] $region, [String] $userName, [String] $password, [String] $tenantId)
if (!$systemName) {
    $systemName = $Env:systemName
}
if (!$region) {
    $region = $Env:region
}
if (!$userName) {
    $userName = $Env:userName
}
if (!$password) {
    $password = $Env:password
}
if (!$tenantId) {
    $tenantId = $Env:tenantId
}

if(!$systemName) {
    $systemName = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resource.  Some resources require globally unique names.  This prefix should guarantee that.'
}
if(!$region) {
    $region = Read-Host -Prompt 'Please provide a region to deploy to.  Hint: WestUS2'
}
if(!$userName) {
    $userName = Read-Host -Prompt 'Please provide the Application (client) ID for a service principle to use for the deployment.'
}
if(!$password) {
    $password = Read-Host -Prompt 'Please provide the service principal secret (password) to use for the deployment.'
}
if(!$tenantId) {
    $tenantId = Read-Host -Prompt 'Please provide the Directory (tenant) ID for the service principal.'
}

$loggingPrefix = "Images Deployment ($systemName)"
$resourceGroupName = "$systemName-images"
$apiName = "$systemName-images-api"
$apiFilePath = "./ContentReactor.Images.Api.zip"
$workerName = "$systemName-images-worker"
$workerFilePath = "./ContentReactor.Images.WorkerApi.zip"

Set-Location "$PSSCriptRoot"

. ./../../scripts/functions.ps1

if (!$systemName) {
    D "Either pass in the '-systemName' parameter when calling this script or 
    set and environment variable with the name: 'systemName'." $loggingPrefix
}
if (!$region) {
    D "Either pass in the '-region' parameter when calling this script or 
    set and environment variable with the name: 'region'." $loggingPrefix
}

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

# https://github.com/Microsoft/azure-pipelines-agent/issues/1816
$command = "az"
$result = ExecuteCommand $command $loggingPrefix "Executing first AZ call to get around Task bug."

$ErrorActionPreference = $old_ErrorActionPreference 

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
$result = ExecuteCommand $command $loggingPrefix "Logging in the Azure CLI"

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $apiName --src $apiFilePath"
$result = ExecuteCommand $command $loggingPrefix "Deploying the API application."

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $workerName --src $workerFilePath"
$result = ExecuteCommand $command $loggingPrefix "Deploying the worker application."

$ErrorActionPreference = $old_ErrorActionPreference 
