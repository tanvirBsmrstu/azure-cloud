# Self hosting agent

### Get public ip of the machine from where ssh will be initiated
```bash
curl ifconfig.me
```

### Variables
```bash
DEV_OPS_URL="https://dev.azure.com/TRHN"
DEV_OPS_PAT=""
DEV_OPS_AGENT_PULL_NAME="trhn-agent"
CF_STACK_NAME="devops-agent"
YOUR_IP=$(curl ifconfig.me)
```

### Create EC2 agent
```bash
aws cloudformation create-stack \
  --stack-name $CF_STACK_NAME \
  --template-body file://devops-agent.yaml \
  --parameters \
    ParameterKey=KeyName,ParameterValue=your-key \
    ParameterKey=MyIP,ParameterValue=$YOUR_IP/32 \
    ParameterKey=DevOpsUrl,ParameterValue=$DEV_OPS_URL \
    ParameterKey=DevOpsPat,ParameterValue=$DEV_OPS_PAT \
    ParameterKey=AgentPool,ParameterValue=$DEV_OPS_AGENT_PULL_NAME
```

### Check status
```bash
# Wait until CREATE_COMPLETE
aws cloudformation describe-stacks --stack-name $CF_STACK_NAME
```

### Get public IP
```bash
aws cloudformation describe-stacks \
  --stack-name $CF_STACK_NAME \
  --query "Stacks[0].Outputs"
```

### SSH
```bash
ssh -i your-key.pem ubuntu@<public-ip>
```

### Delete if not needed anymore
```bash
aws cloudformation delete-stack --stack-name $CF_STACK_NAME
```