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

import ballerina/http;
import ballerina/io;
import ballerina/oauth2;
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

    // Step 1: Batch Create Two Companies
    companies:BatchInputSimplePublicObjectInputForCreate createPayload = {
        inputs: [
            {
                properties: {
                    "name": "Company X",
                    "domain": "companyx.com"
                }
            },
            {
                properties: {
                    "name": "Company Y",
                    "domain": "companyy.com"
                }
            }
        ]
    };

    companies:BatchResponseSimplePublicObject|companies:BatchResponseSimplePublicObjectWithErrors|error createResponse =
        hubSpotCrmCompanies->/companies/batch/create.post(createPayload);

    string companyXId;
    string companyYId;

    if createResponse is companies:BatchResponseSimplePublicObject {
        companyXId = createResponse.results[0].id;
        companyYId = createResponse.results[1].id;
        io:println("Created Company X with ID: ", companyXId);
        io:println("Created Company Y with ID: ", companyYId);
    } else {
        io:println("Error occurred while creating companies: ", createResponse);
        return;
    }

    // Step 2: Get All Companies and Print Count
    companies:GetCrmV3ObjectsCompanies_getpageQueries getQueries = {
        associations: [],
        archived: false,
        propertiesWithHistory: [],
        'limit: 100,
        after: (),
        properties: ["name", "domain", "hs_object_id"]
    };

    companies:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging|error getAllCompaniesResponse =
        hubSpotCrmCompanies->/companies.get(queries = getQueries);

    if getAllCompaniesResponse is companies:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging {
        int initialCount = getAllCompaniesResponse.results.length();
        io:println("Initial company count: ", initialCount);
    } else {
        io:println("Error occurred while retrieving companies: ", getAllCompaniesResponse);
        return;
    }

    // Step 3: Delete Company X
    http:Response|error deleteResponse = hubSpotCrmCompanies->/companies/[companyXId].delete();

    if deleteResponse is http:Response {
        io:println("Deleted Company X with ID: ", companyXId);
    } else {
        io:println("Error occurred while deleting Company X: ", deleteResponse);
        return;
    }

    // Step 4: Get All Companies and Print Count Again
    getAllCompaniesResponse = hubSpotCrmCompanies->/companies.get(queries = getQueries);

    if getAllCompaniesResponse is companies:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging {
        int finalCount = getAllCompaniesResponse.results.length();
        io:println("Final company count after deletion: ", finalCount);
    } else {
        io:println("Error occurred while retrieving companies after deletion: ", getAllCompaniesResponse);
        return;
    }
}

