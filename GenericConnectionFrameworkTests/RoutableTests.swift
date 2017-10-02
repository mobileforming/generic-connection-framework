//
//  RoutableTests.swift
//  GenericConnectionFramework
//
//  Created by Christopher Luc on 8/18/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import XCTest
@testable import GenericConnectionFramework

class RoutableTests: XCTestCase {
    
    func testExampleRoutableEnum() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Router.readUsers.path, "/getUsers")
        XCTAssertEqual(Router.home.path, "/")
        XCTAssertEqual(Router.readUsers.method, HTTPMethod.get)
        XCTAssertEqual(Router.home.method, HTTPMethod.get)
        XCTAssertNil(Router.readUsers.header)
        XCTAssertNil(Router.home.header)
        XCTAssertNil(Router.readUsers.parameters)
        XCTAssertNil(Router.home.parameters)
        XCTAssertNil(Router.readUsers.body)
        XCTAssertNil(Router.home.body)
    }
}

enum Router: Routable {
    
    case readUsers
    case home
    
    var path: String {
        switch self {
        case .readUsers:
            return "/getUsers"
        case .home:
            return "/"
        }
    }
    var method: HTTPMethod {
        return .get
    }
    
    var header: [String : String]? {
        switch self {
        default:
            return nil
        }
    }
    
    var parameters: [String : String]? {
        switch self {
        default:
            return nil
        }
    }
    
    var body: [String : Any]? {
        switch self {
        default:
            return nil
        }
    }
}
