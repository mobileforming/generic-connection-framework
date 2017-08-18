//
//  RoutableTests.swift
//  GenericConnectionFramework
//
//  Created by Christopher Luc on 8/18/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import XCTest

class RoutableTests: XCTestCase {
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertTrue(Router.readUsers.path == "/getUsers")
        XCTAssertTrue(Router.home.path == "/")

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
        default:
            return ""
        }
    }
    var method: String {
        switch self {
        default:
            return HTTPMethod.get.rawValue
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
