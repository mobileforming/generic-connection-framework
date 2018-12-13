//
//  RxGCFTests.swift
//  GenericConnectionFrameworkTests
//
//  Created by Alan Downs on 10/2/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import XCTest
@testable import GenericConnectionFramework

class RxGCFTests: XCTestCase {

	struct TestRoutable: Routable {
		var path: String
		var method: HTTPMethod
		var headers: [String : String]?
		var parameters: [String : String]?
		var body: [String : Any]?
		var needsAuthorization: Bool
	}

	struct TestPost: Codable {
		var title: String
	}

	var gcf: APIClient?
	let urlSession = MockURLSession()

	override func setUp() {
		super.setUp()
		gcf = APIClient(baseURL: "https://jsonplaceholder.typicode.com")
	}

	override func tearDown() {
		gcf = nil
		super.tearDown()
	}

	func testInit() {
		XCTAssertEqual(gcf!.baseURL, "https://jsonplaceholder.typicode.com")
		XCTAssertNil(gcf!.plugin)
	}

	func testSendRequestGET() {
		let route = TestRoutable(path: "/posts/1", method: .get, headers: nil, parameters: nil, body: nil, needsAuthorization: false)
		let exp = expectation(description: "observable get")
		
		gcf!.sendRequest(for: route, completion: { (result: TestPost?, error) in
			XCTAssertNotNil(result)
			XCTAssertTrue(result!.title.contains("sunt aut"))
			exp.fulfill()
		})

		waitForExpectations(timeout: 10, handler: nil)
	}

	func testSendRequestGETData() {
		let route = TestRoutable(path: "/posts/1", method: .get, headers: nil, parameters: nil, body: nil, needsAuthorization: false)
		let exp = expectation(description: "observable get")

		gcf!.sendRequest(for: route, completion: { (data: Data?, error) in
			XCTAssertNotNil(data)
			XCTAssertTrue(String(data: data!, encoding: .utf8)?.contains("sunt aut") ?? false)
			exp.fulfill()
		})

		waitForExpectations(timeout: 10, handler: nil)
	}

	func testSendRequestPOST() {
		let route = TestRoutable(path: "/posts", method: .post, headers: nil, parameters: nil, body: ["title": "test", "body": "test", "userId": 1], needsAuthorization: false)

		let exp = expectation(description: "post request")
        gcf!.sendRequest(for: route) { (success: Bool, error) in
			XCTAssertNil(error)
			XCTAssertTrue(success)
			exp.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func testSendRequestPUT() {
		let route = TestRoutable(path: "/posts", method: .put, headers: nil, parameters: nil, body: ["title": "test", "body": "test", "userId": 1], needsAuthorization: false)

		let exp = expectation(description: "put request")
        gcf!.sendRequest(for: route) { (success: Bool, error) in
			XCTAssertNil(error)
			XCTAssertTrue(success)
			exp.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func testSendRequestParsingError() {
		let route = TestRoutable(path: "/posts", method: .post, headers: nil, parameters: nil, body: nil, needsAuthorization: false)
		let exp = expectation(description: "post request")
		
		gcf!.sendRequest(for: route) { (result: TestPost?, error) in
			if result != nil {
				XCTFail()
			} else if error != nil {
				exp.fulfill()
			}
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func testSendRequestCompletion() {
		let route = TestRoutable(path: "/posts/1", method: .get, headers: nil, parameters: nil, body: nil, needsAuthorization: false)

		let exp = expectation(description: "get request")
		gcf!.sendRequest(for: route) { (post: TestPost?, error) in
			XCTAssertNotNil(post)
			XCTAssertNil(error)
			XCTAssertTrue(post!.title.contains("sunt aut"))
			exp.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

    func testConfigurePlugins() {
        gcf!.configurePlugins([MockGCFPlugin(), MockGCFPlugin()])
        XCTAssertNotNil(gcf!.plugin)
    }

    func testAppendPlugins() {
        gcf?.appendPlugin(MockGCFPlugin())
        XCTAssertNotNil(gcf?.plugin)
        XCTAssertEqual(gcf!.plugin!.plugins.count, 1)

        gcf?.appendPlugin(MockGCFPlugin())
        XCTAssertEqual(gcf!.plugin!.plugins.count, 2)
    }
}
