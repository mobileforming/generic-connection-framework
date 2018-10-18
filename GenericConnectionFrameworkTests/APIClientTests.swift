//
//  APIClientTests.swift
//  GenericConnectionFrameworkTests
//
//  Created by Wesley St. John on 10/17/18.
//  Copyright © 2018 mobileforming LLC. All rights reserved.
//

import XCTest
@testable import GenericConnectionFramework



class APIClientTests: XCTestCase {
    
    let client = APIClient(baseURL: "www.google.com")

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRetry() {
        let plugin = MockGCFPlugin()
        plugin.didReceiveError = GCFError.PluginError.failureRetryRequest
        
        client.configurePlugins([plugin])

        let routable = MockRoutable()
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

}
