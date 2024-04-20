
@description('Location for the resources')
param location string

@description('Tags for all resources')
param tags object = {}

@minLength(3)
@maxLength(24)
@description('The name of the storage account')
param storageAccountName string

@description('The name of our function app resource')
param functionAppName string

@description('The name of the app service plan resource')
param appServicePlanName string

@description('The name of the application insights resource')
param applicationInsightsName string

@secure()
@description('API key for our very interesting API')
param apiKey string

@allowed([
  'S1'
  'B1'
])
param appServicePlanSku string

module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'deploy-bode-${appServicePlanName}'
  params: {
    appServicePlanName: appServicePlanName
    location: location
    appServicePlanSku: appServicePlanSku
  }
}

module bodeFunctionApp 'modules/function-app.bicep' = {
  name: 'deploy-${functionAppName}'
  params: {
    appServicePlanName: appServicePlanName
    appSettings: [
  
      {
        name: 'ApiKey'
        value: apiKey
      }
    ]
    applicationInsightsName: applicationInsightsName
    functionAppName: functionAppName
    storageAccountName: storageAccountName
    location: location
    tags: tags
  }
}

output bodeAppServicePlan string = appServicePlan.outputs.appServicePlanName
output functionAppName string = bodeFunctionApp.outputs.functionAppNameModule
