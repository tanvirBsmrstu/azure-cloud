# Azure Pipelines

## Creating a Self-hosted agent for agent pool [lab link](https://microsoftlearning.github.io/AZ400-DesigningandImplementingMicrosoftDevOpsSolutions/Instructions/Labs/AZ400_M02_L03_Configure_Agent_Pools_and_Understand_Pipeline_Styles.html)

1. Create Resource Group
```bash
RG="trhn-az400-test"
LOCATION="westeurope"
VM_NAME="trhn-agent-win"
USER_NAME="trhn"
USER_PASS="YourStrongPassword123!"
PORT_TO_ACCESS_VM=3389

az group create -n $RG -l $LOCATION
```
2. Check available images
```bash
az vm image list -l $LOCATION --output table
```

3. Create Virtual Machine
```bash
az vm create -g $RG -n $VM_NAME -l $LOCATION \
--image Win2022Datacenter --size Standard_B2ts_v2 \
--assign-identity \
--admin-username $USER_NAME --admin-password $USER_PASS \
--public-ip-sku Standard \
--nsg-rule RDP \
--security-type TrustedLaunch \
--enable-secure-boot true \
--enable-vtpm true



az vm open-port \
  --resource-group $RG \
  --name $VM_NAME \
  --port $PORT_TO_ACCESS_VM

ssh $USER_NAME@172.201.58.72

```

4. Run ssh service on the VM
```bash
az vm run-command invoke \
  --resource-group $RG \
  --name $VM_NAME \
  --command-id RunShellScript \
  --scripts "sudo systemctl enable ssh && sudo systemctl start ssh"


# Check status
 az vm run-command invoke \
  --resource-group $RG \
  --name $VM_NAME \
  --command-id RunShellScript \
  --scripts "sudo systemctl status ssh"
```


4. Configure agent
- Go to Azure DevOps organization
- Go to Project settings -> Agent pools
- Click on "Default" pool
- Click on "New agent"
- Select "Linux" and click on "Download"
```bash
# Download and extract the agent
https://download.agent.dev.azure.com/agent/4.273.0/vsts-agent-linux-x64-4.273.0.tar.gz
```
