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

import ballerina/test;
import ballerina/oauth2;
// import ballerina/io;
import ballerina/http;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

OAuth2RefreshTokenGrantConfig auth = {
       clientId: clientId,
       clientSecret: clientSecret,
       refreshToken: refreshToken,
       credentialBearer: oauth2:POST_BODY_BEARER
};


final Client hubSpotCrmCompanies = check new ({ auth });

@test:Config {}
isolated function testGetAllCompanies() returns error? {
  CollectionResponseSimplePublicObjectWithAssociationsForwardPaging  companies = check hubSpotCrmCompanies->/companies;
  test:assertTrue(companies.results.length() > 0);
};

@test:Config {}
isolated function testBatchRead() returns error? {
    // Define the payload for the request
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

@test:Config {}
isolated function testCreateCompanies() returns error? {
    // Define the payload for creating a company
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

@test:Config {}
isolated function testGetCompanies() returns error? {
    // Define the query parameters
    GetCrmV3ObjectsCompanies_getpageQueries queries = {
        associations: [],
        archived: false,
        propertiesWithHistory: [],
        'limit: 10,
        after: (),
        properties: ["name", "domain", "hs_object_id"]
    };

    // Send the GET request with query parameters
    CollectionResponseSimplePublicObjectWithAssociationsForwardPaging response = check hubSpotCrmCompanies->/companies.get(queries = queries);

    // Assert that the response contains at least one company
    test:assertTrue(response.results.length() > 0, "Expected at least one company to be returned");

}


@test:Config {}
isolated function testSearchCompany() returns error? {
    // Define the payload for the search request
    PublicObjectSearchRequest payload = {
        query: "TestCompany", // Search query
        'limit: 10,         // Limit the results to 10
        after: (),
        sorts: [],
        properties: ["name", "domain", "hs_object_id"], // Properties to include in the response
        filterGroups: []
    };

    // Send the POST request with the payload
    CollectionResponseWithTotalSimplePublicObjectForwardPaging response = check hubSpotCrmCompanies->/companies/search.post(payload);
    test:assertTrue(response.results.length() > 0, "Expected at least one company to match the search criteria");

}


@test:Config {}
isolated function testUpdateCompany() returns error? {
    // Define the company ID to update
    string companyId = "28253323423"; // Replace with the actual company ID

    // Define the payload for updating the company
    SimplePublicObjectInput payload = {
        properties: {
            "name": "Updated TestCompany",  
            "domain": "updateddomain.com"  
        }
    };

    // Send the PATCH request with the payload
    SimplePublicObject response = check hubSpotCrmCompanies->/companies/[companyId].patch(payload);

    test:assertEquals(response.properties["name"], "Updated TestCompany", "The company name was not updated correctly.");
    test:assertEquals(response.properties["domain"], "updateddomain.com", "The company domain was not updated correctly.");

}


@test:Config {}
isolated function testGetCompanyById() returns error? {
    // Define the company ID to retrieve
    string companyId = "28228574530"; 

    // Define query parameters (optional)
    GetCrmV3ObjectsCompaniesCompanyid_getbyidQueries queries = {};

    // Send the GET request
    SimplePublicObjectWithAssociations response = check hubSpotCrmCompanies->/companies/[companyId](queries = queries);

    // Assert the response is not empty
    test:assertTrue(response.id != "", "No company data was retrieved.");

}

@test:Config {}
isolated function testDeleteCompany() returns error? {
    // Define the company ID to delete
    string companyId = "28200512883"; // Replace with the actual company ID to be archived

    // Send the DELETE request
    http:Response response = check hubSpotCrmCompanies->/companies/[companyId].delete();

    // Assert successful deletion (HTTP status code 204 indicates success)
    test:assertEquals(response.statusCode, 204, "Company was not archived successfully.");

}


@test:Config {}
isolated function testBatchUpsert() returns error? {
    // Define the payload for upserting companies
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

    // Send the POST request to upsert companies
    BatchResponseSimplePublicUpsertObject|BatchResponseSimplePublicUpsertObjectWithErrors response = check hubSpotCrmCompanies->/companies/batch/upsert.post(payload);

    // Ensure at least one company was successfully upserted
    test:assertTrue(response.results.length() > 0,
    string `At least one company should be successfully upserted. Found: ${response.results.length()}`);

}



@test:Config {}
isolated function testBatchCreate() returns error? {
    // Define the batch payload for creating companies
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

    // Send the POST request
    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors response = check hubSpotCrmCompanies->/companies/batch/create.post(payload);

    test:assertTrue(response is BatchResponseSimplePublicObject, "Batch creation should return a successful response.");
    
}


@test:Config {}
isolated function testBatchUpdate() returns error? {
    // Define the batch payload for updating companies
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

    // Send the POST request
    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors response = check hubSpotCrmCompanies->/companies/batch/update.post(payload);

    test:assertTrue(response is BatchResponseSimplePublicObject, "Batch update should return a successful response.");
}


@test:Config {}
isolated function testBatchArchive() returns error? {
    // Define the batch payload for archiving companies
    BatchInputSimplePublicObjectId payload = {
        inputs: [
            { id: "28104552201" }, 
            { id: "28152220570" } 
        ]
    };

    // Send the POST request
    http:Response response = check hubSpotCrmCompanies->/companies/batch/archive.post(payload);

    test:assertTrue(response.statusCode == 204, "Batch archive should return a successful status code (204).");
}


@test:Config {}
isolated function testMergeCompanies() returns error? {
    // Define the payload for merging two companies
    PublicMergeInput payload = {
        objectIdToMerge: "28285841794", 
        primaryObjectId: "28207511091" 
    };

    // Send the POST request to merge companies
    SimplePublicObject response = check hubSpotCrmCompanies->/companies/merge.post(payload);
      
    // Ensure the merged object contains the primary object ID
    test:assertTrue(response.id == payload.primaryObjectId, string `Merged company's ID should match the primary object ID. Found: ${response.id}`);
}