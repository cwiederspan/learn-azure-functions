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
-var 'location=eastus2' \
-var 'cosmos_ip_range_filter=75.70.154.88,104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26'

# Apply the script with the specified variable values
terraform apply \
-var 'resource_name=cdw-azfuncdemo-20200825' \
-var 'location=eastus2' \
-var 'cosmos_ip_range_filter=75.70.154.88,104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26'

```
