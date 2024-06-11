
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
    az group list --query "[?name == '$RESOURCE_GROUP']"
    ```

4. **Finding all resources** under a resource group.

    ```bash
    az resource list --resource-group $RESOURCE_GROUP
    ```

5. **Deleting** a resource group with all the other services it has

    ```bash
    az group delete --name $RESOURCE_GROUP --no-wait
    ```

## Azure VMs

- [Availability Set, Update domain, fault domain](https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview)


## App Service plan & Web app

1. **Creating** an app service plan

    ```bash
    $APP_SERVICE_PLAN_NAME = "az204_appservice_plan"

    az appservice plan create   --name $APP_SERVICE_PLAN_NAME \
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

    $AZ_WEB_APP_NAME="ecoshop-007-webapp"

    az webapp create --name $AZ_WEB_APP_NAME --resource-group $RESOURCE_GROUP --plan $APP_SERVICE_PLAN_NAME
    ```

4. **Listing** all web apps

    ```bash
    az webapp list --output table
    ```
    
5. **Checking** the web app. The `DefaultHostName` can also be found from the above command. (default html from the sample app)

    ```bash
    curl $AZ_WEB_APP_NAME.azurewebsites.net
    ```

6. **Deploying** code from **Github**.

    ```bash
    $GITHUB_URL = "https://github.com/Azure-Samples/php-docs-hello-world"
    $GITHUB_BRANCH = "master"

    az webapp deployment source config --help

    az webapp deployment source config  --name $AZ_WEB_APP_NAME \
                                        --resource-group $RESOURCE_GROUP \
                                        --repo-url $GITHUB_URL \
                                        --branch $GITHUB_BRANCH \
                                        --manual-integration
    ```

7. **Retesting** deployed code. Do the same query as step `5`. New deployed changes should be in action.

#### Usefull links

- [Accessing KeyValut from Web App](https://learn.microsoft.com/en-us/samples/azure-samples/app-service-msi-keyvault-dotnet/keyvault-msi-appservice-sample/)


## Azure Functions

- [Send Email from Azure functions using SendGrid](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-sendgrid?tabs=in-process%2Cfunctionsv2&pivots=programming-language-csharp)


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





## Azure Container Registry (ACR)

1. **Creating** an Azure Container Registry

    ```bash
    $AZ_ACR_NAME = "az204-container-registry"

    az acr create --resource-group $RESOURCE_GROUP \
                  --name $AZ_ACR_NAME \
                  --sku Basic
    ```

2. **Building** image, after the image is successfully built, pushes it to your registry. Using the familiar `docker build` format, the `az acr build` command in the Azure CLI takes a context (the set of files to build), sends it to ACR Tasks and, by default, pushes the built image to its registry upon completion.

    Execute the command from `Dockerfile` directory.

    ```bash
    $IMAGE_NAME = "sample/hello-world"
    $IMAGE_NAME_WITH_TAG = "$IMAGE_NAME:v1"

    az acr build --image $IMAGE_NAME_WITH_TAG \
                 --registry $AZ_ACR_NAME \
                 --file Dockerfile .
    ```

3. **Verifying** the results.

    ```bash
    az acr repository list --name $AZ_ACR_NAME --output table
        
        OR see all the tags of an image

    az acr repository show-tags --name $AZ_ACR_NAME \
                                --repository $IMAGE_NAME \
                                --output table    
    ```

4. **Running** the container image from the container registry. The following example uses `$Registry` to specify the registry where you run the command. 

    The `cmd` parameter in this example runs the container in its default configuration, but `cmd` supports other docker run parameters or even other docker commands. ( [Reference](https://learn.microsoft.com/en-us/training/modules/publish-container-image-to-azure-container-registry/6-build-run-image-azure-container-registry) )

    ```bash
    az acr run --registry $AZ_ACR_NAME \
               --cmd '$Registry/$IMAGE_NAME_WITH_TAG' /dev/null
    ```

### Azure Container Instances (ACI)

1. **Creating** unique DNS name to expose the container to the internet, and then the ACI. There are three restart policies `Always`, `Never`, `OnFailure`. The default is `Always`. These can be specified with `--restart-policy` parameter.

    ```bash
    $DNS_NAME_LABEL = "aci-example-$RANDOM"
    $AZURE_CONTAINER_NAME = "az204-container"
    $IMAGE_TO_RUN = "$Registry/$IMAGE_NAME_WITH_TAG"

    az container create --resource-group $RESOURCE_GROUP \
                        --name $AZURE_CONTAINER_NAME \
                        --image $IMAGE_TO_RUN \
                        --ports 80 \
                        --dns-name-label $DNS_NAME_LABEL \
                        --location $AZURE_REGION
    ```

    Environment variable can be passed to the container with `--environment-variables` parameter, such as `--environment-variables "NumWords"="5" "MinLength"="8"`.

    Set a secure environment variable by specifying the `secureValue` property instead of the regular `value` for the variable's type. The two variables defined in the following YAML demonstrate the two variable types. ([Reference](https://learn.microsoft.com/en-us/training/modules/create-run-container-images-azure-container-instances/5-set-environment-variables-azure-container-instances))

    ```yaml
    apiVersion: 2018-10-01
    location: eastus
    name: securetest
    properties:
    containers:
    - name: mycontainer
        properties:
        environmentVariables:
            - name: 'NOTSECRET'
            value: 'my-exposed-value'
            - name: 'SECRET'
            secureValue: 'my-secret-value'
        image: nginx
        ports: []
        resources:
            requests:
            cpu: 1.0
            memoryInGB: 1.5
    osType: Linux
    restartPolicy: Always
    tags: null
    type: Microsoft.ContainerInstance/containerGroups
    ```
    You would run the following command to deploy the container group with YAML:

    ```bash
    az container create --resource-group $RESOURCE_GROUP \
                        --file secure-env.yaml 
    ```

    Mounting volume to the container.  [Reference](https://learn.microsoft.com/en-us/training/modules/create-run-container-images-azure-container-instances/6-mount-azure-file-share-azure-container-instances)

    ```bash
    --azure-file-volume-account-name $ACI_PERS_STORAGE_ACCOUNT_NAME \
    --azure-file-volume-account-key $STORAGE_KEY \
    --azure-file-volume-share-name $ACI_PERS_SHARE_NAME \
    --azure-file-volume-mount-path /aci/logs/
    ```

    OR with the yaml file.

    ```yaml
    apiVersion: '2019-12-01'
    location: eastus
    name: file-share-demo
    properties:
    containers:
    - name: hellofiles
        properties:
        environmentVariables: []
        image: mcr.microsoft.com/azuredocs/aci-hellofiles
        ports:
        - port: 80
        resources:
            requests:
            cpu: 1.0
            memoryInGB: 1.5
        volumeMounts:
        - mountPath: /aci/logs/
            name: filesharevolume
    osType: Linux
    restartPolicy: Always
    ipAddress:
        type: Public
        ports:
        - port: 80
        dnsNameLabel: aci-demo
    volumes:
    - name: filesharevolume
        azureFile:
        sharename: acishare
        storageAccountName: <Storage account name>
        storageAccountKey: <Storage account key>
    tags: {}
    type: Microsoft.ContainerInstance/containerGroups
    ```


2. **Verify** the container is running.

    ```bash
    az container show --resource-group $RESOURCE_GROUP \
                      --name $AZURE_CONTAINER_NAME \
                      --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" \
                      --out table
    ```




### Shared-Access-Signature (SAS token) [ policy based SAS token ]

1. Creating a policy

    ```bash
    $SAS_POLICY_NAME = "az204-sas-policy"
    $SAS_POLICY_PERMISSIONS = "rw" # <(a)dd, (c)reate, (d)elete, (l)ist, (r)ead, or (w)rite>

    az storage container policy create --name $SAS_POLICY_NAME \
                                       --container-name <container name> \
                                       --start <start time UTC datetime> \
                                       --expiry <expiry time UTC datetime> \
                                       --permissions $SAS_POLICY_PERMISSIONS \
                                       --account-key <storage account key> \
                                       --account-name <storage account name> 
    ```



### Azure Key Vault

1. **Creating** a key vault.

    ```bash
    $AZURE_KEY_VAULT_NAME = "az204-keyvault"

    az keyvault create --name $AZURE_KEY_VAULT_NAME \
                       --resource-group $RESOURCE_GROUP \
                       --location $AZURE_REGION
    ```
2. **Adding and Retrieveing** a secret

    ```bash
    az keyvault secret set --vault-name $AZURE_KEY_VAULT_NAME \
                           --name "ExamplePassword" \
                           --value "hVFkk965BuUv"

    az keyvault secret show --name "ExamplePassword" \
                            --vault-name $AZURE_KEY_VAULT_NAME
    ```

### Managed Identities [Reference](https://learn.microsoft.com/en-us/training/modules/implement-managed-identities/4-configure-managed-identities)

1. **System-assigned managed identity**

    1. Enable system-assigned managed identity during creation of an Azure virtual machine

        ```bash
        $VM_NAME = "myVM"

        az vm create --resource-group $RESOURCE_GROUP \ 
                    --name $VM_NAME --image win2016datacenter \ 
                    --generate-ssh-keys \ 
                    --assign-identity \ 
                    --role contributor \
                    --scope mySubscription \
                    --admin-username azureuser \ 
                    --admin-password myPassword12
        ```

    2. Enable system-assigned managed identity on an existing Azure virtual machine

        ```bash
        az vm identity assign -g $RESOURCE_GROUP -n $VM_NAME
        ```
    3. Similarly, assign to **Azure App Configuration store** [Reference](https://learn.microsoft.com/en-us/training/modules/implement-azure-app-configuration/5-secure-app-configuration-data)

        ```bash
        $APP_CONFIG_STORE_NAME = "myTestAppConfigStore"

        az appconfig identity assign --resource-group $RESOURCE_GROUP \
                                     --name  $APP_CONFIG_STORE_NAME
        ```

2. **User-assigned identity**

    1. Create a user-assigned identity

        ```bash
        $USER_ASSIGNED_IDENTITY_NAME = "myUserAssignedIdentity"

        az identity create -g $RESOURCE_GROUP -n $USER_ASSIGNED_IDENTITY_NAME
        ```

    2. Assign a user-assigned managed identity during the creation of an Azure virtual machine

        ```bash
        az vm create    --resource-group $RESOURCE_GROUP \
                        --name $VM_NAME \
                        --image Ubuntu2204 \
                        --admin-username <USER NAME> \
                        --admin-password <PASSWORD> \
                        --assign-identity $USER_ASSIGNED_IDENTITY_NAME \
                        --role <ROLE> \
                        --scope <SUBSCRIPTION>
        ```

    3. Assign a user-assigned managed identity to an existing Azure virtual machine

        ```bash
        az vm identity assign -g $RESOURCE_GROUP -n $VM_NAME --identities $USER_ASSIGNED_IDENTITY_NAME
        ```

    4. Similarly, assign to **Azure App Configuration store** [Reference](https://learn.microsoft.com/en-us/training/modules/implement-azure-app-configuration/5-secure-app-configuration-data)

        ```bash
        az appconfig identity assign -name $APP_CONFIG_STORE_NAME \
                                     --resource-group $RESOURCE_GROUP \
                                     --identities $USER_ASSIGNED_IDENTITY_NAME
        ```

#### Usefull links
- [OAath 2.0](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow)


### API Management

1. **Creating** an API management instance. [Reference](https://learn.microsoft.com/en-us/training/modules/explore-api-management/8-exercise-import-api)

    ```bash
    $PUBLISHER_EMAIL = "tanvirh03@gmail.com"
    $API_MANAGEMENT_NAME = "az-204-apim"

    az apim create  --name $API_MANAGEMENT_NAME \
                    --location $AZURE_REGION \
                    --publisher-email $PUBLISHER_EMAIL  \
                    --resource-group $RESOURCE_GROUP \
                    --publisher-name AZ204-APIM-Exercise \
                    --sku-name Developer
    ```

## Event-based solutions

### Azure Event Grid

1. **Registering** an Event Grid resource provider. [Reference](https://learn.microsoft.com/en-us/training/modules/azure-event-grid/8-event-grid-custom-events)
    <div style="background-color: #dbc18c; border-left: 15px solid #2196F3; padding: 10px; color: #000000; font-style: italic;">
    <strong>Note</strong> This step is only needed on subscriptions that haven't previously used Event Grid.
    </div>

    ```bash
    az provider register --namespace Microsoft.EventGrid
    ```
    To check the status run the following command.
    ```bash
    az provider show --namespace Microsoft.EventGrid --query "registrationState"
    ```

2. **Creating** custom Topic. The name must be **unique** because it's part of the DNS entry

    ```bash
    $EVENT_GRID_CUSTOM_TOPIC_NAME = "az204-event-grid-custom-topic"

    az eventgrid topic create --name $EVENT_GRID_CUSTOM_TOPIC_NAME \
                              --location $AZURE_REGION \
                              --resource-group $RESOURCE_GROUP
    ```

3. **Creating** a message endpoint. Before subscribing to the custom topic, we need to create the endpoint for the event message. Typically, the endpoint takes actions based on the event data. The following script uses a prebuilt web app that displays the event messages. The deployed solution includes an App Service plan, an App Service web app, and source code from GitHub.

    ```bash
    $mySiteName="az204-egsite"
    $mySiteURL="https://${mySiteName}.azurewebsites.net"

    az deployment group create --resource-group $RESOURCE_GROUP \
                               --template-uri "https://raw.githubusercontent.com/Azure-Samples/azure-event-grid-viewer/main/azuredeploy.json" \
                               --parameters siteName=$mySiteName hostingPlanName=viewerhost

    echo "Your web app URL: ${mySiteURL}"
    ```

4. **Subscribing** to a custom topic.

    ```bash
    endpoint="${mySiteURL}/api/updates"
    subId=$(az account show --subscription "" | jq -r '.id')
    sourceResourceID="/subscriptions/$subId/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.EventGrid/topics/$EVENT_GRID_CUSTOM_TOPIC_NAME"

    $EVENT_SUBSCRIPTION_NAME = "az204ViewerSub"
    
    az eventgrid event-subscription create --name $EVENT_SUBSCRIPTION_NAME \
                                           --source-resource-id $sourceResourceID \
                                           --endpoint $endpoint
    ```

    View your web app again, and notice that a subscription validation event has been sent to it.

    OR [with retry policy](https://learn.microsoft.com/en-us/training/modules/azure-event-grid/4-event-grid-delivery-retry)

    ```bash
    az eventgrid event-subscription create --name $EVENT_SUBSCRIPTION_NAME \
                                           --topic-name $EVENT_GRID_CUSTOM_TOPIC_NAME \
                                           --resource-group $RESOURCE_GROUP \
                                           --endpoint $endpoint \
                                           --max-delivery-attempts 18
    ```

5. **Sending** an event to your custom topic

    ```bash
    topicEndpoint=$(az eventgrid topic show --name $EVENT_GRID_CUSTOM_TOPIC_NAME -g $RESOURCE_GROUP --query "endpoint" --output tsv)
    key=$(az eventgrid topic key list --name $EVENT_GRID_CUSTOM_TOPIC_NAME -g $RESOURCE_GROUP --query "key1" --output tsv)

    event='[ {"id": "'"$RANDOM"'", "eventType": "recordInserted", "subject": "myapp/vehicles/motorcycles", "eventTime": "'`date +%Y-%m-%dT%H:%M:%S%z`'", "data":{ "make": "Contoso", "model": "Northwind"},"dataVersion": "1.0"} ]'

    curl -X POST -H "aeg-sas-key: $key" -d "$event" $topicEndpoint
    ```

Another option is [Azure Event Hubs](https://learn.microsoft.com/en-us/training/modules/azure-event-hubs/6-event-hubs-programming-guide).

## Message-based solution

### Azure Service BUS [Reference](https://learn.microsoft.com/en-us/training/modules/discover-azure-message-queue/6-send-receive-messages-service-bus)

1. **Creating** a Service Bus namespace

    ```bash
    $SERVICE_BUS_NAMESPACE_NAME = "az204-service-bus-namespace"

    az servicebus namespace create --name $SERVICE_BUS_NAMESPACE_NAME \
                                   --resource-group $RESOURCE_GROUP \
                                   --location $AZURE_REGION
    ```

2. **Creating** a Service Bus queue

    ```bash
    $SERVICE_BUS_QUEUE_NAME = "az204-service-bus-queue"
    
    az servicebus queue create --name $SERVICE_BUS_QUEUE_NAME \
                               --namespace-name $SERVICE_BUS_NAMESPACE_NAME \
                               --resource-group $RESOURCE_GROUP \
    ```

Another option is [Azure Queue Storage](https://learn.microsoft.com/en-us/training/modules/discover-azure-message-queue/8-queue-storage-code-examples)

## Implement Caching

### Azure Redis Cache

1. **Creating** Redis cache. The name has to be **unique** in the Azure. [Reference](https://learn.microsoft.com/en-us/training/modules/develop-for-azure-cache-for-redis/5-console-app-azure-cache-redis)

    ```bash
    $REDIS_CACHE_NAME = "az204-redis"
    az redis create --name $redisName \
                    --location $AZURE_REGION \
                    --resource-group $RESOURCE_GROUP \
                    --sku Basic --vm-size c0
    ```

### Azure  content delivery network (CDN)

A content delivery network (CDN) is a distributed network of servers that can efficiently deliver web content to users. [Reference](https://learn.microsoft.com/en-us/training/modules/develop-for-storage-cdns/3-control-cache-behavior)








### Usefull links

- [Markdown Guide](https://www.markdownguide.org)
