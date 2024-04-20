
@description('Location for the resources')
param location string = resourceGroup().location

@description('Tags for all resources')
param tags object = {}

@minLength(3)
@maxLength(24)
@description('The name of the storage account')
param storageAccountName string

@minLength(3)
@maxLength(24)
@description('The name of the SFTP storage account')
param sftpStorageAccountName string

@description('The name of the application insights resource')
param applicationInsightsName string

@description('The name of the app service plan resource')
param appServicePlanName string

@secure()
@description('API key for our very interesting API')
param apiKey string

@description('The name of our function app resource')
param functionAppName string

@description('Name of the SKU')
@allowed([
  'Standard_GRS'
  'Standard_LRS'
])
param storageAccountSku string

@allowed([
  'S1'
  'B1'
])
param appServicePlanSku string = 'B1'


module storageAccount 'modules/storage-account.bicep' = {
  name: 'deploy-${storageAccountName}'
  params: {
    location: location
    tags: tags
    storageAccountName: storageAccountName
    storageAccountSku: storageAccountSku
  }
}

module sftpStorageAccount 'modules/storage-account.bicep' = {
  name: 'deploy-${sftpStorageAccountName}'
  params: {
    location: location
    tags: tags
    storageAccountName: sftpStorageAccountName
    storageAccountSku: storageAccountSku
    isSftpEnabled: true
  }
}

module applicationInsights 'modules/application-insights.bicep' = {
  name: 'bode-deploy-${applicationInsightsName}'
  params: {
    applicationInsightsName: applicationInsightsName
    location: location
  }
}



module compute 'compute.bicep' = {
  name: 'compute-deploy'
  params: {
    apiKey: apiKey
    applicationInsightsName: applicationInsightsName
    appServicePlanName: appServicePlanName
    functionAppName: functionAppName
    appServicePlanSku: appServicePlanSku
    location: location
    storageAccountName: storageAccountName
    tags: tags
  }
}


output bodeStorageAccountName string = storageAccount.outputs.storageAccountName
output applicationInsightsName string = applicationInsights.outputs.applicationInsightsName
output appServicePlanName string = compute.outputs.bodeAppServicePlan
output functionAppName string = compute.outputs.functionAppName
