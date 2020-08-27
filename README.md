# Learn Azure Functions

A hands-on approach to learning Azure Functions using technologies such as Devcontainer, Terraform and Azure DevOps Pipelines.

## Prerequisites

You will need the following apps and utilities installed to complete any tasks.

* [Docker Desktop](https://docs.docker.com/get-docker/)

* [Remote Development Extension Pack in VS Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)

## Starting from Scratch

```bashrc
# Create an empty directory on your local computer
mkdir MyAzFunctions

# Open the empty folder in VS Code
cd MyAzFunctions

code .

# At this point, you need to use the Remote Devcontainer option in VS Code to create
# a devcontainer for the project.

# COMING SOON: Demo/instructions to create devcontainer for dotnet 3.0

# From the terminal window in VS Code
mkdir FunctionApp

cd FunctionApp

func init

func new -l c# -n MyFunction

```
