//
//  DefaultGCFTests.swift
//  GenericConnectionFrameworkTests
//
//  Created by Alan Downs on 9/22/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import XCTest
import RxSwift
@testable import GenericConnectionFramework

class DefaultGCFTests: XCTestCase {
	
	struct TestRoutable: Routable {
		var path: String
		var method: HTTPMethod
		var headers: [String : String]?
		var parameters: [String : String]?
		var body: [String : Any]?
	}
	
	struct TestPost: Codable {
		var title: String
	}
	
	var gcf: DefaultGCF?
	let urlSession = MockURLSession()
	let disposeBag = DisposeBag()
	
    override func setUp() {
        super.setUp()
		gcf = DefaultGCF(baseURL: "https://jsonplaceholder.typicode.com")
//		gcf!.urlSession = urlSession
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
		let route = TestRoutable(path: "/posts/1", method: .get, headers: nil, parameters: nil, body: nil)
		
		let exp = expectation(description: "get request")
		gcf!.sendRequest(for: route) { (post: TestPost?, error) in
			XCTAssertNotNil(post)
			XCTAssertNil(error)
			XCTAssertTrue(post!.title.contains("sunt aut"))
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func testSendRequestPOST() {
		let route = TestRoutable(path: "/posts", method: .post, headers: nil, parameters: nil, body: ["title": "test", "body": "test", "userId": 1])

		let exp = expectation(description: "post request")
		gcf!.sendRequest(for: route) { (success, error) in
			XCTAssertNil(error)
			XCTAssertTrue(success)
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func testSendRequestPUT() {
		let route = TestRoutable(path: "/posts", method: .put, headers: nil, parameters: nil, body: ["title": "test", "body": "test", "userId": 1])
		
		let exp = expectation(description: "put request")
		gcf!.sendRequest(for: route) { (success, error) in
			XCTAssertNil(error)
			XCTAssertTrue(success)
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func testSendRequestParsingError() {
		let route = TestRoutable(path: "/posts", method: .post, headers: nil, parameters: nil, body: nil)
		
		let exp = expectation(description: "get request")
		gcf!.sendRequest(for: route) { (post: TestPost?, error) in
			XCTAssertNil(post)
			XCTAssertNotNil(error)
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func testSendRequestObservable() {
		let route = TestRoutable(path: "/posts/1", method: .get, headers: nil, parameters: nil, body: nil)
		let exp = expectation(description: "observable post")
		
		let observable: Observable<TestPost> = gcf!.sendRequest(for: route)
		observable.subscribe { (event) in
			switch event {
			case .next(let post):
				XCTAssertNotNil(post)
				XCTAssertTrue(post.title.contains("sunt aut"))
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .completed:
				exp.fulfill()
			}
		}.disposed(by: disposeBag)
		
		waitForExpectations(timeout: 10, handler: nil)
	}
}
