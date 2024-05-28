# azure-cloud


## Azure CLI general help

```
az find "az group create --tags" (find most populer commands that has "___")
    OR
az group create --help (if you already know the command)
```

## Azure Resource group

1. **Creating** a resource group. (Optional parameter `--tags` are used for logical grouping )

    ```
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

    ```
    az group list
        OR
    az group list --output table
    ```

3. **Finding** a resource group using the `--query` parameter

    ```
    az group list --query "[?name == '$resourceGroupName']"
    ```


## App Service plan

1. **Creating** an app service plan

    ```
    $AZURE_APP_PLAN = "az204_appservice_plan"

    az appservice plan create   --name $AZURE_APP_PLAN \
                                --resource-group $RESOURCE_GROUP \
                                --location $AZURE_REGION \
                                --sku FREE
    ```

2. **Listing** all app service plan

    ```
    az appservice plan list --output table
    ```

3. **Creating Web app** in the app service plan. Web app is required to deploy the application code. All the web apps in a service plan follows the same scale in/out rule that is given on the app service plan.

    ```
    az appservice plan create --help

    az webapp create --name $AZURE_WEB_APP --resource-group $RESOURCE_GROUP --plan $AZURE_APP_PLAN
    ```

4. **Listing** all web apps

    ```
    az webapp list --output table
    ```
    
5. **Checking** the web app. The `DefaultHostName` can also be found from the above command. (default html from the sample app)

    ```
    curl $AZURE_WEB_APP.azurewebsites.net
    ```

6. **Deploying** code from **Github**.

    ```
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



