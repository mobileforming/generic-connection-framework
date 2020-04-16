//
//  rest_gcfTests.swift
//  rest-gcfTests
//
//  Created by Alan Downs on 4/15/20.
//  Copyright © 2020 Alan Downs. All rights reserved.
//

import XCTest
import GenericConnectionFramework

class BoolTypeTests: XCTestCase {
    
    var apiClient: APIClient!
    
    override func setUp() {
        apiClient = APIClient(baseURL: "https://httpstat.us")

        let plugin = ErrorPlugin()
        apiClient.appendPlugin(plugin)
    }

    func test200() throws {
        let exp = expectation(description: "")
        apiClient.sendRequest(for: TestRoutable.ok) { (success: Bool, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }

    func test204() throws {
        let exp = expectation(description: "")
        apiClient.sendRequest(for: TestRoutable.noContent) { (success: Bool, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func test404() throws {
        let exp = expectation(description: "")
        apiClient.sendRequest(for: TestRoutable.notFound) { (success: Bool, error) in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            print(error.debugDescription)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func test503() throws {
        let exp = expectation(description: "")
        apiClient.sendRequest(for: TestRoutable.serverUnavailable) { (success: Bool, error) in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            print(error.debugDescription)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}

enum TestRoutable: Routable {
    case ok
    case noContent
    case notFound
    case serverUnavailable
    
    var path: String {
        switch self {
        case .ok:
            return "/200"
        case .noContent:
            return "/204"
        case .notFound:
            return "/404"
        case .serverUnavailable:
            return "/503"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    var headers: [String : String]? {
        return nil
    }
    
    var parameters: [String : String]? {
        return nil
    }
    
    var body: [String : AnyHashable]? {
        return nil
    }
    
    var needsAuthorization: Bool {
        return false
    }
}

class ErrorPlugin: GCFPlugin {
    func willSendRequest(_ request: inout URLRequest, needsAuthorization: Bool) -> Error? {
        return nil
    }
    
    func didReceive(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) -> Error? {
        if let response = response as? HTTPURLResponse, !(200..<300).contains(response.statusCode) {
            return GCFError.requestError(NSError(domain: "SityoRemote", code: response.statusCode, userInfo:nil))
        }
        
        return nil
    }
}
