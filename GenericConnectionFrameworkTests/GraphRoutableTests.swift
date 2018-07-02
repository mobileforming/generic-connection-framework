//
//  GraphRoutableTests.swift
//  GenericConnectionFrameworkTests
//
//  Created by Alan Downs on 5/29/18.
//  Copyright © 2018 mobileforming LLC. All rights reserved.
//

import XCTest
@testable import GenericConnectionFramework

class GraphRoutableTests: XCTestCase {
	
	struct TestGraphRoute: GraphRoutable {
		var query: String
		var variables: [String:Any]?
		var method: HTTPMethod
		var headers: [String:String]?
		var parameters: [String:String]?
		var needsAuthorization: Bool
	}
    
	func testQueryData() {
		let route = TestGraphRoute(query: "testquery", variables: nil, method: .get, headers: nil, parameters: nil, needsAuthorization: false)
		
		let body = route.body
		XCTAssertNotNil(body)
		XCTAssertNotNil(body!["query"])
		XCTAssertNil(body!["variables"])
		XCTAssertEqual(body!["query"] as! String, "testquery")
	}
	
	func testQueryAndVariableData() {
		let route = TestGraphRoute(query: "testquery", variables: ["testvar": 1], method: .get, headers: nil, parameters: nil, needsAuthorization: false)
		
		let body = route.body
		XCTAssertNotNil(body)
		XCTAssertNotNil(body!["query"])
		XCTAssertEqual(body!["query"] as! String, "testquery")
		
		let variables = body!["variables"] as? [String:Any]
		XCTAssertNotNil(variables)
		XCTAssertEqual(variables!["testvar"] as! Int, 1)
	}
	
	func testPath() {
		let route = TestGraphRoute(query: "testquery", variables: ["testvar": 1], method: .get, headers: nil, parameters: nil, needsAuthorization: false)
		XCTAssertTrue(route.path.isEmpty)
	}
}
