
#!/bin/bash

ACI_LOGIN_SERVER="adoacracr.azurecr.io"
IMAGE_NAME="acibuildagent"
IMAGE_VERSION="latest"
LOCATION="uksouth"
ACI_RESOURCE_GROUP="adoacr-aci-rg"


docker build -t "$ACI_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_VERSION" .

az acr login --name $ACI_LOGIN_SERVER

docker push "$ACI_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_VERSION" 

az group create --location $LOCATION -n $ACI_RESOURCE_GROUP

az deployment group create -g $ACI_RESOURCE_GROUP --template-file arm/deploy.json --parameters @arm/deploy.parameters.json