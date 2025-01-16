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

import ballerina/http;
import ballerina/log;

service on new http:Listener(9090) {

    resource function get companies(string properties = "", string archived = "false", int:Signed32 'limit = 10) returns json|http:Response {
        log:printInfo("Mock GET request received for companies with properties: " + properties + ", archived: " + archived);
        json mockedResponse = {
            "results": [
                {
                    "id": "12345",
                    "properties": {
                        "name": "Company A",
                        "domain": "companya.com",
                        "city": "City A",
                        "industry": "Technology",
                        "phone": "123-456-789",
                        "state": "State A",
                        "lifecyclestage": "lead"
                    },
                    "createdAt": "2025-01-01T10:00:00Z",
                    "updatedAt": "2025-01-01T12:00:00Z",
                    "archived": false
                }
            ],
            "paging": {
                "next": {
                    "after": "https://api.hubapi.com/companies/v3?page=2"
                }
            }
        };
        return mockedResponse;
    }

    resource function post companies/batch/read(@http:Payload BatchReadInputSimplePublicObjectId payload)
    returns json|http:Response {

        log:printInfo("Mock POST request received for batch read with payload: " + payload.toJson().toString());

        json mockedResponse = {
            "status": "COMPLETE",
            "startedAt": "2025-01-01T08:00:00Z",
            "completedAt": "2025-01-01T08:05:00Z",
            "results": [
                {
                    "id": "28253323423",
                    "properties": {
                        "name": "Company J",
                        "domain": "companyj.com",
                        "city": "City J",
                        "industry": "Technology",
                        "phone": "123-456-789",
                        "state": "State J",
                        "lifecyclestage": "lead"
                    },
                    "createdAt": "2025-01-01T10:00:00Z",
                    "updatedAt": "2025-01-01T12:00:00Z",
                    "archived": false
                },
                {
                    "id": "28200512883",
                    "properties": {
                        "name": "Company K",
                        "domain": "companyk.com",
                        "city": "City K",
                        "industry": "Finance",
                        "phone": "987-654-321",
                        "state": "State K",
                        "lifecyclestage": "customer"
                    },
                    "createdAt": "2025-01-02T10:00:00Z",
                    "updatedAt": "2025-01-02T12:00:00Z",
                    "archived": false
                }
            ]
        };

        return mockedResponse;
    }

    resource function post companies(@http:Payload SimplePublicObjectInputForCreate payload) returns json|http:Response {
        log:printInfo("Mock POST request received for company creation with payload: " + payload.toJson().toString());

        // Simulate a successful creation response with the same company data
        json mockedResponse = {
            "id": "12345",
            "properties": {
                "name": payload.properties["name"],
                "domain": payload.properties["domain"],
                "city": payload.properties["city"],
                "industry": payload.properties["industry"],
                "phone": payload.properties["phone"],
                "state": payload.properties["state"],
                "lifecyclestage": payload.properties["lifecyclestage"]
            },
            "createdAt": "2025-01-09T11:20:04.835Z",
            "updatedAt": "2025-01-09T11:20:05.764Z",
            "archived": false
        };
        return mockedResponse;
    }

};
