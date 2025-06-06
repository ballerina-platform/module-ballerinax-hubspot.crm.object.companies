// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
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

import ballerina/oauth2;
import ballerina/os;
import ballerina/test;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
final string serviceUrl = isLiveServer ? "https://api.hubapi.com/crm/v3/objects" : "http://localhost:9090";

final string clientId = os:getEnv("HUBSPOT_CLIENT_ID");
final string clientSecret = os:getEnv("HUBSPOT_CLIENT_SECRET");
final string refreshToken = os:getEnv("HUBSPOT_REFRESH_TOKEN");

final Client hubSpotCrmCompanies = check initClient();

isolated function initClient() returns Client|error {
    if isLiveServer {
        OAuth2RefreshTokenGrantConfig auth = {
            clientId: clientId,
            clientSecret: clientSecret,
            refreshToken: refreshToken,
            credentialBearer: oauth2:POST_BODY_BEARER
        };
        return check new ({auth}, serviceUrl);
    }
    return check new ({
        auth: {
            token: "test-token"
        }
    }, serviceUrl);
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetAllCompanies() returns error? {
    CollectionResponseSimplePublicObjectWithAssociationsForwardPaging companies = check hubSpotCrmCompanies->/companies;
    test:assertTrue(companies.results.length() > 0);
};

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testBatchRead() returns error? {
    BatchReadInputSimplePublicObjectId payload = {
        propertiesWithHistory: [],
        inputs: [
            {id: "28253323423"},
            {id: "28200512883"}
        ],
        properties: []
    };

    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors response = check hubSpotCrmCompanies->/companies/batch/read.post(payload);
    test:assertTrue(response.results.length() > 0, "Expected non-zero amount of companies");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testCreateCompanies() returns error? {
    SimplePublicObjectInputForCreate payload = {
        properties: {
            "name": "Maga",
            "domain": "maga.com",
            "city": "Colombo",
            "industry": "MARKETING_AND_ADVERTISING",
            "phone": "111-111-111",
            "state": "Western",
            "lifecyclestage": "lead"
        },
        associations: []
    };

    SimplePublicObject response = check hubSpotCrmCompanies->/companies.post(payload);
    test:assertEquals(response.properties["name"], "Maga", "Expected company name to match");
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveServer
}
isolated function testGetCompanies() returns error? {
    GetCrmV3ObjectsCompaniesGetPageQueries queries = {
        associations: [],
        archived: false,
        propertiesWithHistory: [],
        'limit: 10,
        after: (),
        properties: ["name", "domain", "hs_object_id"]
    };

    CollectionResponseSimplePublicObjectWithAssociationsForwardPaging response = check hubSpotCrmCompanies->/companies.get(queries = queries);
    test:assertTrue(response.results.length() > 0, "Expected at least one company to be returned");
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveServer
}
isolated function testSearchCompany() returns error? {
    PublicObjectSearchRequest payload = {
        query: "TestCompany",
        'limit: 10, // Limit the results to 10
        after: (),
        sorts: [],
        properties: ["name", "domain", "hs_object_id"], // Properties to include in the response
        filterGroups: []
    };

    CollectionResponseWithTotalSimplePublicObjectForwardPaging response = check hubSpotCrmCompanies->/companies/search.post(payload);
    test:assertTrue(response.results.length() > 0, "Expected at least one company to match the search criteria");

}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveServer
}
isolated function testUpdateCompany() returns error? {
    string companyId = "28253323423"; // Replace with the actual company ID
    SimplePublicObjectInput payload = {
        properties: {
            "name": "Updated TestCompany",
            "domain": "updateddomain.com"
        }
    };
    SimplePublicObject response = check hubSpotCrmCompanies->/companies/[companyId].patch(payload);
    test:assertEquals(response.properties["name"], "Updated TestCompany", "The company name was not updated correctly.");
    test:assertEquals(response.properties["domain"], "updateddomain.com", "The company domain was not updated correctly.");
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveServer
}
isolated function testGetCompanyById() returns error? {
    string companyId = "28228574530";
    GetCrmV3ObjectsCompaniesCompanyIdGetByIdQueries queries = {};
    SimplePublicObjectWithAssociations response = check hubSpotCrmCompanies->/companies/[companyId](queries = queries);
    test:assertTrue(response.id != "", "No company data was retrieved.");

}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveServer
}
isolated function testDeleteCompany() returns error? {
    string companyId = "28200512883"; // Replace with the actual company ID to be archived
    _ = check hubSpotCrmCompanies->/companies/[companyId].delete();
    test:assertTrue(true, "Company deleted successfully.");
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveServer
}
isolated function testBatchUpsert() returns error? {
    BatchInputSimplePublicObjectBatchInputUpsert payload = {
        inputs: [
            {
                idProperty: "url", // Use "url" as the primary unique identifier
                id: "https://hubspot.com/company1",
                properties: {
                    "name": "HubSpot",
                    "domain": "hubspot.com",
                    "url": "https://hubspot.com/company1"
                }
            },
            {
                idProperty: "url",
                id: "https://hubspot.com/company2",
                properties: {
                    "name": "TestCompany",
                    "domain": "testcompany.com",
                    "url": "https://hubspot.com/company2"
                }
            }
        ]
    };

    BatchResponseSimplePublicUpsertObject|BatchResponseSimplePublicUpsertObjectWithErrors response = check hubSpotCrmCompanies->/companies/batch/upsert.post(payload);
    test:assertTrue(response.results.length() > 0,
            string `At least one company should be successfully upserted. Found: ${response.results.length()}`);

}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveServer
}
isolated function testBatchCreate() returns error? {
    BatchInputSimplePublicObjectInputForCreate payload = {
        inputs: [
            {
                properties: {
                    "name": "CompanyOne",
                    "domain": "companyone.com"
                }
            },
            {
                properties: {
                    "name": "CompanyTwo",
                    "domain": "companytwo.com"
                }
            }
        ]
    };

    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors response = check hubSpotCrmCompanies->/companies/batch/create.post(payload);
    test:assertTrue(response !is BatchResponseSimplePublicObjectWithErrors, "Batch creation should return a successful response.");
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveServer
}
isolated function testBatchUpdate() returns error? {
    BatchInputSimplePublicObjectBatchInput payload = {
        inputs: [
            {
                id: "28166846756",
                properties: {
                    "name": "UpdatedCompanyOne",
                    "domain": "updatedcompanyone.com"
                }
            },
            {
                id: "28174006653",
                properties: {
                    "name": "UpdatedCompanyTwo",
                    "domain": "updatedcompanytwo.com"
                }
            }
        ]
    };
    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors response = check hubSpotCrmCompanies->/companies/batch/update.post(payload);
    test:assertTrue(response !is BatchResponseSimplePublicObjectWithErrors, "Batch update should return a successful response.");
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveServer
}
isolated function testBatchArchive() returns error? {
    BatchInputSimplePublicObjectId payload = {
        inputs: [
            {id: "28104552201"},
            {id: "28152220570"}
        ]
    };
    _ = check hubSpotCrmCompanies->/companies/batch/archive.post(payload);
    test:assertTrue(true, "Batch archive should return a successful response.");
}
