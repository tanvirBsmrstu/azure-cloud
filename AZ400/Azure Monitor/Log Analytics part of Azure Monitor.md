#  Log Analytics part of Azure Monitor


### Step 1: Create Log Analytics workspace

1. Setup variables
```bash
RG="trhn-az400-test"
Location="westeurope"
WorkspaceName="trhn-az400-loganalytics"

# List of solutions to enable
Solutions=("CapacityPerformance" "LogManagement" "ChangeTracking" "ProcessInvestigator")
```

2. Create Resource Group
```bash
az group create -n $RG -l $Location
```
3. Create Log Analytics workspace
```bash
az monitor log-analytics workspace create -g $RG -n $WorkspaceName -l $Location
```

4. Get Workspace Resource ID (needed for solutions)
```bash
WorkspaceId=$(az monitor log-analytics workspace show -g $RG -n $WorkspaceName --query id -o tsv)
```
5. Enable solutions (optional)
```bash
for sol in "${Solutions[@]}"
do
    az monitor log-analytics solution create \
        -g $RG \
        -n $sol \
        --workspace $WorkspaceId \
        --solution-type $sol
done
```
