# Self hosting agent



### Variables
```bash
AWS_KEY_NAME="ec2-agent-key-trhn"
AWS_LOCATION="eu-central-1"
DEV_OPS_URL="https://dev.azure.com/TRHN"
DEV_OPS_PAT="<your-devops-pat>"
DEV_OPS_AGENT_POOL_NAME="trhn-agent-pool"
CF_STACK_NAME="devops-agent"
```

### Check available Images and ID
```bash
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --query "Images[*].[ImageId,Name]" \
  --region $AWS_LOCATION \
  --output table
```

### Import pubKey
```bash
aws ec2 import-key-pair \
  --key-name $AWS_KEY_NAME \
  --public-key-material fileb://id_rsa.pub \
  --tag-specifications 'ResourceType=key-pair,Tags=[
      {Key=Project,Value=az400},
      {Key=Name,Value=DevOpsKey}
    ]'
```

### Create EC2 agent
```bash
aws cloudformation create-stack \
  --stack-name $CF_STACK_NAME \
  --template-body file://ec2-devops-agent.yml \
  --region $AWS_LOCATION \
  --parameters \
    ParameterKey=KeyName,ParameterValue=$AWS_KEY_NAME \
    ParameterKey=DevOpsUrl,ParameterValue=$DEV_OPS_URL \
    ParameterKey=DevOpsPat,ParameterValue=$DEV_OPS_PAT \
    ParameterKey=AgentPool,ParameterValue=$DEV_OPS_AGENT_POOL_NAME
```

### Check status
```bash
# Wait until CREATE_COMPLETE
aws cloudformation describe-stacks --stack-name $CF_STACK_NAME

## OR

aws cloudformation wait stack-create-complete \
  --stack-name $CF_STACK_NAME
```

### Get public IP
```bash
aws cloudformation describe-stacks \
  --stack-name $CF_STACK_NAME \
  --query "Stacks[0].Outputs"
```

### private key too open issue
```bash
cp id_rsa ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa
ssh ubuntu@3.71.49.48
cat /var/log/user-data.log
```

### Delete if not needed anymore
```bash
aws cloudformation delete-stack --stack-name $CF_STACK_NAME
```

### Create a Azure Service Principle
```bash
az ad sp create-for-rbac \
  --name trhn-az400-self-hosted-ec2-agent-sp \
  --role contributor \
  --scopes /subscriptions/5846011c-45f9-4b00-9233-20eb703544f4/resourceGroups/az400 \
  --sdk-auth
```
Should output like 
```json
{
  "clientId": "86866233-0c9d-4663-8331-b335a7685813",
  "clientSecret": "secret",
  "subscriptionId": "5846011c-45f9-4b00-9233-20eb703544f4",
  "tenantId": "d6676032-7674-4de8-bf51-42424d9e74bd",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### Or using federated credential
``` bash
# From DevOps
ISSUER="https://login.microsoftonline.com/d6676032-7674-4de8-bf51-42424d9e74bd/v2.0"
SUBJECT="/eid1/c/pub/t/MmBn1nR26E2_UUJCTZ50vQ/a/rISbSSETf0KqFyZ8ppdXmA/sc/cb8f37c5-d63b-4930-b158-e1e344639f05/af012fee-7fc7-45f8-a7bb-0511cdf1b80c"

APP_ID=$(az ad app create --display-name trhn-az400-devops-app --query appId -o tsv)
az ad sp create --id $APP_ID

az role assignment create \
  --assignee $APP_ID \
  --role Contributor \
  --scope /subscriptions/5846011c-45f9-4b00-9233-20eb703544f4/resourceGroups/az400


SP_OBJECT_ID="051f17a0-f47e-4267-a3fd-5d886f26981b"
az role assignment create \
  --assignee-object-id $SP_OBJECT_ID \
  --assignee-principal-type ServicePrincipal \
  --role Contributor \
  --scope /subscriptions/5846011c-45f9-4b00-9233-20eb703544f4/resourceGroups/az-400-pay-go


az ad app federated-credential create \
  --id $APP_ID \
  --parameters "{
    \"name\": \"az400-devops-service-connection-fd\",
    \"issuer\": \"$ISSUER\",
    \"subject\": \"$SUBJECT\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"
```


```bash
RG="az400"
SERVICEPLANNAME='az400m03l08-sp1'
az appservice plan create -g $RG -n $SERVICEPLANNAME --sku F1

SUFFIX=$RANDOM$RANDOM
az webapp create -g $RG -p $SERVICEPLANNAME -n RGATES-$SUFFIX-DevTest
az webapp create -g $RG -p $SERVICEPLANNAME -n RGATES-$SUFFIX-Prod
```