# Setup Up the Azure Resources

## Terraform Init

```bash

# Use remote storage
terraform init --backend-config ./backend-secrets.tfvars

```

## Terraform Plan and Apply

```bash

# Run the plan to see the changes
terraform plan \
-var 'resource_name=cdw-azfuncdemo-20200825' \
-var 'location=eastus2'

# Apply the script with the specified variable values
terraform apply \
-var 'resource_name=cdw-azfuncdemo-20200825' \
-var 'location=eastus2'

```
