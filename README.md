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
    $resourceGroupName = "az_204"
    $location = "westeurope"

    $tagKey = "exam"
    $tagValue = "az-204-prep"
    $mytag = "$tagKey=$tagValue"

    az group create --name $resourcegroupName --location $location --tags $mytag
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


##

