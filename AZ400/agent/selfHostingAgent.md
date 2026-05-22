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