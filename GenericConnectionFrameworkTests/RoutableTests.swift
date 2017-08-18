//
//  RoutableTests.swift
//  GenericConnectionFramework
//
//  Created by Christopher Luc on 8/18/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import XCTest

class RoutableTests: XCTestCase {
    
    func testExampleRoutableEnum() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertTrue(Router.readUsers.path == "/getUsers")
        XCTAssertTrue(Router.home.path == "/")
        XCTAssertTrue(Router.readUsers.method == "GET")
        XCTAssertTrue(Router.home.method == "GET")
        XCTAssertTrue(Router.readUsers.header == nil)
        XCTAssertTrue(Router.home.header == nil)
        XCTAssertTrue(Router.readUsers.parameters == nil)
        XCTAssertTrue(Router.home.parameters == nil)
    }
    
}

enum Router : Routable {
    
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
    var method: String {
        switch self {
        default:
            return "GET"
        }
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
    
}
