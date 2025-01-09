// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.org).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/oauth2;
// import ballerina/http;
import ballerinax/hubspot.crm.obj.companies;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

companies:OAuth2RefreshTokenGrantConfig auth = {
    clientId,
    clientSecret,
    refreshToken,
    credentialBearer: oauth2:POST_BODY_BEARER
};

public function main() returns error? {
    final companies:Client hubSpotCrmCompanies = check new ({auth});

    // Step 1: Create Company J
    companies:SimplePublicObjectInputForCreate companyJPayload = {
        properties: {
            "name": "Company J",
            "domain": "companyj.com"
        },
        associations: []
    };
    companies:SimplePublicObject|error companyJResponse = hubSpotCrmCompanies->/companies.post(companyJPayload);

    string companyJId;
    if companyJResponse is companies:SimplePublicObject {
        companyJId = companyJResponse.id;
        io:println("Created Company J with ID: ", companyJId);
    } else {
        io:println("Failed to create Company J: ", companyJResponse);
        return;
    }

    // Step 2: Create Company K
    companies:SimplePublicObjectInputForCreate companyKPayload = {
        properties: {
            "name": "Company K",
            "domain": "companyk.com"
        },
        associations: []
    };
    companies:SimplePublicObject|error companyKResponse = hubSpotCrmCompanies->/companies.post(companyKPayload);

    string companyKId;
    if companyKResponse is companies:SimplePublicObject {
        companyKId = companyKResponse.id;
        io:println("Created Company K with ID: ", companyKId);
    } else {
        io:println("Failed to create Company K: ", companyKResponse);
        return;
    }

    // Step 3: Update Company J's Name and Domain
    companies:SimplePublicObjectInput companyJUpdatePayload = {
        properties: {
            "name": "Updated Company J",
            "domain": "updatedcompanyj.com"
        }
    };
    companies:SimplePublicObject|error updateResponse = hubSpotCrmCompanies->/companies/[companyJId].patch(companyJUpdatePayload);

    if updateResponse is companies:SimplePublicObject {
        io:println("Updated Company J with new name and domain.");
    } else {
        io:println("Failed to update Company J: ", updateResponse);
        return;
    }

    // Step 4: Merge Company J into Company K (Keep Company K as Primary)
    companies:PublicMergeInput mergePayload = {
        objectIdToMerge: companyJId,
        primaryObjectId: companyKId
    };
    companies:SimplePublicObject|error mergeResponse = hubSpotCrmCompanies->/companies/merge.post(mergePayload);

    if mergeResponse is companies:SimplePublicObject {
        io:println("Merged Company J into Company K. Final Company ID: ", mergeResponse.id);
    } else {
        io:println("Failed to merge Company J into Company K: ", mergeResponse);
        return;
    }
}
