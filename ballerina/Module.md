## Overview

[HubSpot](https://www.hubspot.com) is an AI-powered customer relationship management (CRM) platform.

The `ballerinax/module-ballerinax-hubspot.crm.obj.companies` package offers APIs to connect and interact with the [HubSpot companies API](https://api.hubapi.com/crm/v3/objects/companies) endpoints, specifically based on the [HubSpot REST API](https://developers.hubspot.com/docs/reference/api/crm/objects/companies).

Using this API, users can develop applications easily that enables you to manage companies easily.

## Setup guide

To use the HubSpot Marketing Events connector, you must have access to the HubSpot API through a HubSpot developer account and a HubSpot App under it. Therefore you need to register for a developer account at HubSpot if you don't have one already.

### Step 1: Create/Login to a HubSpot Developer Account

If you have an account already, go to the [HubSpot developer portal](https://app.hubspot.com/)

If you don't have a HubSpot Developer Account you can sign up to a free account [here](https://developers.hubspot.com/get-started)

### Step 2 (Optional): Create a Developer Test Account

Within app developer accounts, you can create a [developer test account](https://developers.hubspot.com/beta-docs/getting-started/account-types#developer-test-accounts) under your account to test apps and integrations without affecting any real HubSpot data.

> **Note:** These accounts are only for development and testing purposes. In production you should not use Developer Test Accounts.

1. Go to Test Account section from the left sidebar.

    ![Hubspot developer portal](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.object.companies/main/docs/resources/test_acc_1.png)

2. Click Create developer test account.

    ![Hubspot developer portal](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.object.companies/main/docs/resources/test_acc_2.png)

3. In the dialogue box, give a name to your test account and click create.

    ![Hubspot developer portal](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.object.companies/main/docs/resources/test_acc_3.png)

### Step 3: Create a HubSpot App under your account.

1. In your developer account, navigate to the "Apps" section. Click on "Create App"
   ![Hubspot developer portal](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.object.companies/main/docs/resources/create_app_1.png)

2. Provide the necessary details, including the app name and description.

### Step 4: Configure the Authentication Flow.

1. Move to the Auth Tab.

   ![Hubspot developer portal](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.object.companies/main/docs/resources/create_app_2.png)


2. In the Scopes section, add the following scopes for your app using the "Add new scope" button.

   - `crm.objects.companies.read`
   - `crm.objects.companies.write`

   ![Hubspot developer portal](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.object.companies/main/docs/resources/scope_set.png)

3. Add your Redirect URI in the relevant section. You can also use `localhost` addresses for local development purposes. Click Create App.

   ![Hubspot developer portal](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.object.companies/main/docs/resources/create_app_final.png)

### Step 5: Get your Client ID and Client Secret

- Navigate to the Auth section of your app. Make sure to save the provided Client ID and Client Secret.

   ![Hubspot developer portal](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.object.companies/main/docs/resources/get_credentials.png)


### Step 6: Setup Authentication Flow

Before proceeding with the Quickstart, ensure you have obtained the Access Token using the following steps:

1. Create an authorization URL using the following format:

   ```
   https://app.hubspot.com/oauth/authorize?client_id=<YOUR_CLIENT_ID>&scope=<YOUR_SCOPES>&redirect_uri=<YOUR_REDIRECT_URI>
   ```

   Replace the `<YOUR_CLIENT_ID>`, `<YOUR_REDIRECT_URI>` and `<YOUR_SCOPES>` with your specific value.

2. Paste it in the browser and select your developer test account to intall the app when prompted.

   ![Hubspot developer portal](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.object.companies/main/docs/resources/install_app.png)

3. A code will be displayed in the browser. Copy the code.

4. Run the following curl command. Replace the `<YOUR_CLIENT_ID>`, `<YOUR_REDIRECT_URI`> and `<YOUR_CLIENT_SECRET>` with your specific value. Use the code you received in the above step 3 as the `<CODE>`.

   - Linux/macOS

     ```bash
     curl --request POST \
     --url https://api.hubapi.com/oauth/v1/token \
     --header 'content-type: application/x-www-form-urlencoded' \
     --data 'grant_type=authorization_code&code=<CODE>&redirect_uri=<YOUR_REDIRECT_URI>&client_id=<YOUR_CLIENT_ID>&client_secret=<YOUR_CLIENT_SECRET>'
     ```

   - Windows

     ```bash
     curl --request POST ^
     --url https://api.hubapi.com/oauth/v1/token ^
     --header 'content-type: application/x-www-form-urlencoded' ^
     --data 'grant_type=authorization_code&code=<CODE>&redirect_uri=<YOUR_REDIRECT_URI>&client_id=<YOUR_CLIENT_ID>&client_secret=<YOUR_CLIENT_SECRET>'
     ```

   This command will return the access token necessary for API calls.

   ```json
   {
     "token_type": "bearer",
     "refresh_token": "<Refresh Token>",
     "access_token": "<Access Token>",
     "expires_in": 1800
   }
   ```

5. Store the access token securely for use in your application.

## Quickstart

To use the `HubSpot CRM Companies Connector` connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

Import the `hubspot.crm.obj.companies` module.

````ballerina
import ballerinax/hubspot.crm.obj.companies;
````

### Step 2: Instantiate a new connector

1. Create a `companies:OAuth2RefreshTokenGrantConfig` with the obtained access token and initialize the connector with it.

````ballerina
configurable companies:OAuth2RefreshTokenGrantConfig & readonly auth = ?;

final companies:Client hubSpotCrmCompanies = check new ({ auth });
````

2. Create a Config.toml file and, configure the obtained credentials in the above steps as follows:

````toml
[auth]
clientId = "<Client Id>"
clientSecret =  "<Client Secret>"
refreshToken = "<Refresh Token>"
credentialBearer =  "POST_BODY_BEARER"
````

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

#### Create a company

```ballerina
companies:SimplePublicObjectInputForCreate newCompany = {
    properties: {
        "name": "NewCompany",
        "domain": "newcompany.com",
        "city": "Colombo",
        "industry": "MARKETING_AND_ADVERTISING",
        "phone": "011-222-333",
        "state": "Western",
        "lifecyclestage": "lead"
    },
    associations: []
};

companies:SimplePublicObject response = check hubSpotCrmCompanies->/companies.post(newCompany);

```

#### List companies

```ballerina
companies:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging companies = check hubSpotCrmCompanies->/companies;

```

### Step 4: Run the Ballerina application

````bash
bal run
````

## Examples

The `Ballerina HubSpot CRM Companies Connector` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/module-ballerinax-hubspot.crm.object.companies/tree/main/examples/), covering the following use cases:

1. [Create Count Delete Companies](https://github.com/ballerina-platform/module-ballerinax-hubspot.crm.object.companies/tree/main/examples/Company_create_count_delete) - see how the HubSpot API can be used to create, count and delete companies.
2. [Update and Merge Companies](https://github.com/ballerina-platform/module-ballerinax-hubspot.crm.object.companies/tree/main/examples/Company_update_merge) - see how the HubSpot API can be used to merge and update companies.
