# Setup Up the Azure Resources

## Terraform Init

```bash

# Use remote storage
terraform init \
--backend-config ./backend-secrets.tfvars \
--backend-config "key=state.tfstate"

```

## Execution

```bash

# Run the plan to see the changes
terraform plan \
-var 'name=cdw-azfuncdemo-20200825' \
-var 'location=westus2'


# Apply the script with the specified variable values
terraform apply \
-var 'name=cdw-azfuncdemo-20200825' \
-var 'location=westus2'

```
