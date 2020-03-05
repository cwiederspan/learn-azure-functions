# learn-azure-functions
A hands-on approach to learning Azure Functions

## References

https://github.com/Azure/azure-functions-core-tools


## Create a new Function

```bash

func init my-azure-function --dotnet

cd my-azure-function

func new --name HttpExample --template "HTTP trigger"

func start

# Or, debug from the VS Code debug pane

```