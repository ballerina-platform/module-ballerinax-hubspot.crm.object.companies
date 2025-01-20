## Create, count and delete Companies in Hubspot

This use case demonstrates how the `hubspot.crm.obj.companies` API can be utilized to Create, count and delete companies in Hubspot. The example involves a sequence of actions that leverage the Hubspot CRM API v3 to automate the process of editing companies. For the initial starting point we have used the batch creation API to create two companies.

## Prerequisites

### 1. Setup the Hubspot developer account

Refer to the [Setup guide](README.md#setup-guide) to obtain necessary credentials (client Id, client secret, Refresh tokens).

### 2. Configuration

Create a `Config.toml` file in the example's root directory and, provide your Hubspot account related configurations as follows:

```toml
clientId = "<Client ID>"
clientSecret = "<Client Secret>"
refreshToken = "<Access Token>"
```

## Run the example

Execute the following command to run the example:

```bash
bal run
```