# Create Azure Functions with IaC

## Terraform

```bash

# No remote storage here
terraform init

# Apply the script with the specified variable values
terraform apply \
-var 'name=cdw-azfunction-20200720' \
-var 'location=westus2'

```
