
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

@description('App settings for the function app')
param appSettings array

@description('The name of the application insights resource')
param applicationInsightsName string

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: appServicePlanName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'

var requiredAppSettings = [
  {
    name: 'AzureWebJobsStorage'
    value: storageAccountConnectionString
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appInsights.properties.InstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appInsights.properties.ConnectionString
  }
  {
    name: 'FUNCTION_EXTENSION_VERSION'
    value: '~4'
  }
  {
    name: 'FUNCTION_EXTENSION_RUNTIME'
    value: 'dotnet'
  }
]

resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      windowsFxVersion: 'DOTNETCORE|LTS'
      alwaysOn: true
      appSettings: union(appSettings, requiredAppSettings)
    }
  }
}


output functionAppNameModule string = functionApp.name
