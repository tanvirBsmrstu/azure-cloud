
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
4. **Deleting** a resource group with all the other services it has

    ```bash
    az group delete --name $RESOURCE_GROUP --no-wait
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


<div style="background-color: #dbc18c; border-left: 15px solid #2196F3; padding: 10px; color: #000000; font-style: italic;">
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

### Azure Blob Storage

Azure Blob storage is Microsoft's object storage solution for the cloud. Blob storage is optimized for storing massive amounts of unstructured data such as text or binary data, e.g. serving images, video, audio or writing logs.

**Access tiers:**  [Reference](https://learn.microsoft.com/en-us/training/modules/explore-azure-blob-storage/2-blob-storage-overview)

- **Hot :** optimized for frequent access of objects; the highest storage costs, but the lowest access costs.  New storage accounts are created in the hot tier by default
- **Cool :**  infrequently accessed and stored for at least 30 days.
- **Cold :**  infrequently accessed and stored for a minimum of 90 days.
- **Archieve :**  is available only for individual block blobs. The archive tier is optimized for data that can tolerate several hours of retrieval latency and remains in the Archive tier for at least 180 days. The archive tier is the most cost-effective option for storing data, but accessing that data is more expensive than accessing data in the hot or cool tiers.

**Containers :**
A container organizes a set of blobs, similar to a directory in a file system. A storage account can include an unlimited number of containers, and a container can store an unlimited number of blobs.

**Blobs :** 
Azure Storage supports three types of blobs ([Reference](https://learn.microsoft.com/en-us/training/modules/explore-azure-blob-storage/3-blob-storage-resources)) :

1. **Block blobs** store text and binary data. Block blobs are made up of blocks of data that can be managed individually. Block blobs can store up to about 190.7 TiB.
2. **Append blobs** are made up of blocks like block blobs, but are optimized for append operations. Append blobs are ideal for scenarios such as logging data from virtual machines.
3. **Page blobs** store random access files up to 8 TB in size. Page blobs store virtual hard drive (VHD) files and serve as disks for Azure virtual machines.

#### Adding lifecyle management policy [Reference](https://learn.microsoft.com/en-us/training/modules/manage-azure-blob-storage-lifecycle/4-add-policy-blob-storage)

**Remember :** A lifecycle management policy must be read or written in full. Partial updates aren't supported.

1. Create a json policy

    ```json
    {
        "rules": [
            {
            "enabled": true,
            "name": "move-to-cool",
            "type": "Lifecycle",
            "definition": {
                "actions": {
                "baseBlob": {
                    "tierToCool": {
                    "daysAfterModificationGreaterThan": 30
                    }
                }
                },
                "filters": {
                "blobTypes": [
                    "blockBlob"
                ],
                "prefixMatch": [
                    "sample-container/log"
                ]
                }
            }
            }
        ]
    }
    ```

2. Adding policy to the storage account

    ```bash
    $AZURE_STORAGE_ACCOUNT_MGMT_POLICY = "@policy.json"

    az storage account management-policy create --account-name $AZURE_STORAGE_ACCOUNT \
                                                --resource-group $RESOURCE_GROUP \
                                                --policy $AZURE_STORAGE_ACCOUNT_MGMT_POLICY
    ```



## Azure Cosmos DB

Azure Cosmos DB is a fully managed NoSQL database designed to provide low latency, elastic scalability of throughput, well-defined semantics for data consistency, and high availability.

[An excelent description of consistancy level](https://learn.microsoft.com/en-us/training/modules/explore-azure-cosmos-db/5-choose-cosmos-db-consistency-level) .

**Key benefits of global distribution :** [Reference](https://learn.microsoft.com/en-us/training/modules/explore-azure-cosmos-db/2-cosmos-db-benefits)

With its novel multi-master replication protocol, every region supports both writes and reads. The multi-master capability also enables:

- Unlimited elastic write and read scalability.
- 99.999% read and write availability all around the world.
- Guaranteed reads and writes served in less than 10 milliseconds at the 99th percentile.

Your application can perform **near real-time** reads and writes against all the regions you chose for your database. Azure Cosmos DB internally handles the data replication between regions with consistency level guarantees of the level you've selected.

Running a database in multiple regions worldwide increases the availability of a database. If one region is unavailable, other regions **automatically** handle application requests. Azure Cosmos DB offers 99.999% read and write availability for multi-region databases.


1. **Creating** an Azure Cosmos DB

    ```bash
    $AZURE_COSMOS_DB_ACCOUNT_NAME = "az204-cosmosdb"

    az cosmosdb create --name $AZURE_COSMOS_DB_ACCOUNT_NAME --resource-group $RESOURCE_GROUP
    ```
    Record the `documentEndpoint` shown in the JSON response.

2. Retrieving the `PrimaryMasterKey`

    ```bash
    az cosmosdb keys list --name $AZURE_COSMOS_DB_ACCOUNT_NAME --resource-group $RESOURCE_GROUP
    ```




















### Usefull links

- [Markdown Guide](https://www.markdownguide.org)
