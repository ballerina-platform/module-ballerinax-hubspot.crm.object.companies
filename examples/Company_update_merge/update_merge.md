## Create, Update, and Merge Companies in HubSpot

This use case demonstrates how the `hubspot.crm.obj.companies` API can be utilized to create, update, and merge companies in HubSpot. The example involves a sequence of actions using the HubSpot CRM API v3 to automate the process of managing company data. The workflow includes creating two companies, updating one company's details, and merging the two companies, keeping one as the primary.

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