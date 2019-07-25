//
//  APIClientTests.swift
//  GenericConnectionFrameworkTests
//
//  Created by Wesley St. John on 10/17/18.
//  Copyright © 2018 mobileforming LLC. All rights reserved.
//

import XCTest
@testable import GenericConnectionFramework

struct MockCodable: Codable {
    var key: String?
}

class APIClientTests: XCTestCase {
    
    let client = APIClient(baseURL: "www.google.com")
    var session = MockURLSession()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        session.dataTaskCount = 0
        client.urlSession = session
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDataAsCodable() {
        let routable = MockRoutable()
        
        let exp = expectation(description: "wait for response yo")
        client.sendRequest(for: routable) { (result: Data?, error) in
            XCTAssertNotNil(result)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
    }

    func testRetry() {
        let plugin = MockGCFPlugin()
        plugin.didReceiveError = GCFError.PluginError.failureRetryRequest
        
        client.configurePlugins([plugin])
        
        // The reason for this (rather than using MockRoutable here) is to have a new dictionary created
        // from a dictionary literal each time one of the dictionary properties (headers, parameters,
        // body) is referenced. This will randomize the ordering of each dictionary's key/value pairs
        // in the dictionary's internal storage, which is necessary to thoroughly test APIClient's
        // retry handling mechanism.
        struct CustomRoutable: Routable {
            var path: String { return "/some/arbitrary/path" }
            var method: HTTPMethod { return .post }
            var headers: [String: String]? { return ["header1": "value1", "header2": "value2"] }
            var parameters: [String: String]? { return ["parameter1": "value1", "parameter2": "value2"] }
            var body: [String: AnyHashable]? { return ["key1": "value1", "key2": "value2", "key3": "value3"] }
            var needsAuthorization: Bool { return false }
        }
        
        let routable = CustomRoutable()
        let exp = expectation(description: "wait for response yo")
        client.sendRequest(for: routable, numAuthRetries: 2) { (dict: [String: Any]?, error) in
            
            guard let error = error as? GCFError else {
                XCTFail("should have gotten an error")
                return
            }
            if case GCFError.pluginError = error {
                // good
            } else {
                XCTFail("wrong type of error")
            }
            
            XCTAssertEqual(plugin.didReceiveCalledCount, 3)
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10.0)        
    }

    func testConcurrentEqualRequests() {
        let routable = MockRoutable()
        let dispatchGroup = DispatchGroup()
        var resultCount = 0
        
        for _ in 0...9 {
            dispatchGroup.enter()
            client.sendRequest(for: routable) { (mockCodable: MockCodable?, error) in
                resultCount += 1
                dispatchGroup.leave()
            }
        }
        
        let result = dispatchGroup.wait(timeout: .now() + 10.0)
        
        XCTAssertEqual(resultCount, 10)
        switch result {
        case .success:
            XCTAssertEqual(session.dataTaskCount, 1)
        case .timedOut:
            XCTFail("Data tasks timed out for some reason")
        }
        
    }
}

