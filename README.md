# devops-build-agent-aci

The following demonstrates creating an Azure DevOps build agent hosted in an Azure Container Instance.
It is mostly based on the following article. [Running a self-hosted agent in Docker](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops).

The build agent has 2 tools installed on it, Azure CLI and Terraform.

There are 2 parts to the deploy.  Build the infrastructure for the ACI to run on a vnet, and create the ACI.  I use terraform to deploy the infrastructure in an isolated resource group.  The ACI is deployed using mix of docker commands, the azure CLI and an ARM template.  The ACI is deployed to a seperate resource group so as not to polute the terraform state. 

## 1. Build the Infrastructure

The terraform script (/terraform) deploys the following.

* An Azure container registry (ACR) to host the docker image
* A Virtual Network (VNet) to similate an environment the ACI build agent could deploy resources to.
* A service principal with permissions to pull images from the ACR.

The account you run this terraform script with must have permissions to create those resources in an azure subscription.

To run the script, navigate the /terraform folder and in a terminal (I used Ubuntu shell running on WSLv2 ) run 

    terraform init

    terraform apply -auto-approve

(Note: the auto-approve on the last command bypasses the normal "are you sure?" prompt for speed)

If all deploys successfully you should have a set of outputs that look something like this...

    acr_login_server = adoacracr.azurecr.io
    sp_app_id = <SOME GUID>
    sp_object_id = <SOME OTHER GUID>
    sp_password = <RANDOM PASSWORD>
    subnet_id = /subscriptions/<SUB ID>/resourceGroups/adoacr-rg/providers/Microsoft.Network/virtualNetworks/adoacr-vnet/subnets/aci

Make a note of these, you will need them for the next step.

## 2. Build the docker image and deploy to ACI

Before you start you are going to need a couple of bits of information.

* The url of your azure devops org (e.g. https://dev.azure.com/myorg)
* A Personal Access Token for Azure DevOps [see here for details](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops)
* docker installed locally (I used docker desktop on WSLv2)
* Azure CLI installed locally

An example of the steps below can be found in the [create_aci script](/buildagent/create_aci.sh).

Navigate to the buildagent folder.(/buildagent)

login to the ACR

    az acr login --name <acr_login_server>

Build the docker image (substitute the `<x>` values accordingly)

    docker build -t "<acr_login_server>/acibuildagent:latest" .

Push the docker image to ACR

    docker push "<acr_login_server>/acibuildagent:latest"

Create a resource group

    az group create --location <location> -n <new_resource_group_name>

deploy the ARM template to the resource group

    az deployment group create -g <new_resource_group_name> --template-file arm/deploy.json --parameters imageName="<acr_login_server>/acibuildagent:latest" devOpsUrl="<devops_url>" devOpsPatToken="<devops_pat>" acrLoginName="<acr_login_server>" acrLoginUser="<sp_app_id>" acrLoginPassword="<sp_password>" subnetId="<subnet_id>"

alternately you can create an ARM parameters file with this format

    {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "imageName": {
                "value": ""
            },
            "devOpsUrl": {
                "value": ""
            },
            "devOpsPatToken": {
                "value": ""
            },
            "acrLoginName": {
                "value": ""
            },
            "acrLoginUser": {
                "value": ""
            },
            "acrLoginPassword": {
                "value": ""
            },
            "subnetId": {
                "value": ""
            }        
        }
    }

and use the following command to deploy the template (assuming the parameters file is called deploy.parameters.json in the arm folder).

    az deployment group create -g <new_resource_group_name> --template-file arm/deploy.json --parameters @arm/deploy.parameters.json

The end result of this is that an ACI is deployed and connected to the default agent pool in azure devops.



