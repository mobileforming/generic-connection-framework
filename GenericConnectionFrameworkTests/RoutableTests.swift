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
        XCTAssertNil(Router.readUsers.headers)
        XCTAssertNil(Router.home.headers)
        XCTAssertNil(Router.readUsers.parameters)
        XCTAssertNil(Router.home.parameters)
        XCTAssertNil(Router.readUsers.body)
        XCTAssertNil(Router.home.body)
    }
    
    func testHashableRoutable() {
        let r1 = Router.die(method: "strangulation")
        let r2 = Router.die(method: "strangulation")
        let r3 = Router.die(method: "stabbing")
        let r4 = Router.readUsers
        let r5 = Router.home
        let r6 = Router.home
        
        let hr1 = HashableRoutable(routable: r1)
        let hr2 = HashableRoutable(routable: r2)
        let hr3 = HashableRoutable(routable: r3)
        let hr4 = HashableRoutable(routable: r4)
        let hr5 = HashableRoutable(routable: r5)
        let hr6 = HashableRoutable(routable: r6)
        
        XCTAssertTrue(hr1 == hr2)
        XCTAssertFalse(hr1 == hr3)
        XCTAssertFalse(hr1 == hr4)
        XCTAssertTrue(hr5 == hr6)
        
        let dict: [HashableRoutable: String?] = [hr1: "Routable 1", hr3: "Routable 3"]
        // since hr1 and hr2 are equal (according to Hashable), they should get the same value from the dict
        guard let string1 = dict[hr1], let string2 = dict[hr2], let string3 = dict[hr3] else {
            XCTFail("Could not get value from dictionary using HashableRoutable as key")
            return
        }
        XCTAssertEqual(string1, string2)
        XCTAssertFalse(string1 == string3)
    }
    
}

enum Router: Routable {
    
    case readUsers
    case home
    case die(method: String)
    
    var path: String {
        switch self {
        case .readUsers:
            return "/getUsers"
        case .home:
            return "/"
        case .die(let method):
            return "/die/\(method)"
        }
    }
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var headers: [String : String]? {
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
