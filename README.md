
# azure-cloud


## Azure CLI general help

1. **find** operator

    ```bash
    az find "az group create --tags" (find most populer commands that has "___")
        OR
    az group create --help (if you already know the command)
    ```

2. If you're not sure which region to specify for the `--location` parameter, you can retrieve a list of supported regions for your subscription with the `az account list-locations` command.

    ```bash
    az account list-locations \
                    --query "[].{Region:name}" \
                    --out table
    ```

## Azure Resource group

1. **Creating** a resource group. (Optional parameter `--tags` are used for logical grouping )

    ```bash
    $RESOURCE_GROUP = "az_204"
    $AZURE_REGION = "westeurope"

    $tagKey = "exam"
    $tagValue = "az-204-prep"
    $MY_TAG = "$tagKey=$tagValue"

    az group create --name $RESOURCE_GROUP \
                    --location $AZURE_REGION \
                    --tags $MY_TAG
    ```

2. **Listing all** resource groups

    ```bash
    az group list
        OR
    az group list --output table
    ```

3. **Finding** a resource group using the `--query` parameter

    ```bash
    az group list --query "[?name == '$resourceGroupName']"
    ```


## App Service plan

1. **Creating** an app service plan

    ```bash
    $AZURE_APP_PLAN = "az204_appservice_plan"

    az appservice plan create   --name $AZURE_APP_PLAN \
                                --resource-group $RESOURCE_GROUP \
                                --location $AZURE_REGION \
                                --sku FREE
    ```

2. **Listing** all app service plan

    ```bash
    az appservice plan list --output table
    ```

3. **Creating Web app** in the app service plan. Web app is required to deploy the application code. All the web apps in a service plan follows the same scale in/out rule that is given on the app service plan.

    ```bash
    az appservice plan create --help

    az webapp create --name $AZURE_WEB_APP --resource-group $RESOURCE_GROUP --plan $AZURE_APP_PLAN
    ```

4. **Listing** all web apps

    ```bash
    az webapp list --output table
    ```
    
5. **Checking** the web app. The `DefaultHostName` can also be found from the above command. (default html from the sample app)

    ```bash
    curl $AZURE_WEB_APP.azurewebsites.net
    ```

6. **Deploying** code from **Github**.

    ```bash
    $GITHUB_URL = "https://github.com/Azure-Samples/php-docs-hello-world"
    $GITHUB_BRANCH = "master"

    az webapp deployment source config --help

    az webapp deployment source config  --name $AZURE_WEB_APP \
                                        --resource-group $RESOURCE_GROUP \
                                        --repo-url $GITHUB_URL \
                                        --branch $GITHUB_BRANCH \
                                        --manual-integration
    ```

7. **Retesting** deployed code. Do the same query as step `5`. New deployed changes should be in action.



## Azure Storage Account
A storage account is a container that groups a set of Azure Storage services together. Only data services from Azure Storage can be included in a storage account (Azure Blobs, Azure Files, Azure Queues, and Azure Tables). See details on [storage account type and parameters](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-cli#storage-account-type-parameters).


<div class="style-custom-note">
 <strong>Remember</strong> that the name of your storage account must be <strong>unique across Azure</strong>; since it is being used in the URL
</div>

1. **Creating** azure storage account.

    ```bash
    $AZURE_STORAGE_ACCOUNT = "az204_storage_account"

    az storage account create   --name $AZURE_STORAGE_ACCOUNT \
                                --resource-group $RESOURCE_GROUP \
                                --location $AZURE_REGION \
                                --sku Standard_LRS \
                                --kind StorageV2 \
                                --allow-blob-public-access false
    ```

2. **Deleting** storage account. See details on [how to recover a deleted storage account](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-recover).

    ```bash
    az storage account delete --name $AZURE_STORAGE_ACCOUNT --resource-group  $RESOURCE_GROUP
    ```




























### Usefull links

- [Markdown Guide](https://www.markdownguide.org)




<style>
.style-custom-note {
    background-color: #dbc18c;
    border-left: 15px solid #2196F3;
    padding: 10px;
    color: #000000;
    font-style: italic;
}
</style>
