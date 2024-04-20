az deployment group create \
    --subscription udemy-courses \
    --resource-group bicep-course \
    --name the_main_the_main_deployment \
    --template-file main.bicep \
    --parameters @main.parameters.json