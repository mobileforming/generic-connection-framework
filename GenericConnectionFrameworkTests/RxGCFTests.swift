//
//  RxGCFTests.swift
//  GenericConnectionFrameworkTests
//
//  Created by Alan Downs on 10/2/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import XCTest
import RxSwift
@testable import GenericConnectionFramework

class RxGCFTests: XCTestCase {
	
	struct TestRoutable: Routable {
		var path: String
		var method: HTTPMethod
		var header: [String : String]?
		var parameters: [String : String]?
		var body: [String : Any]?
	}
	
	struct TestPost: Codable {
		var title: String
	}
	
	var gcf: RxGCF?
	let urlSession = MockURLSession()
	let disposeBag = DisposeBag()
	
	override func setUp() {
		super.setUp()
		gcf = RxGCF(baseURL: "https://jsonplaceholder.typicode.com")
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
		let route = TestRoutable(path: "/posts/1", method: .get, header: nil, parameters: nil, body: nil)
		let exp = expectation(description: "observable get")
		
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
	
	func testSendRequestPOST() {
		let route = TestRoutable(path: "/posts", method: .post, header: nil, parameters: nil, body: ["title": "test", "body": "test", "userId": 1])
		
		let exp = expectation(description: "post request")
		gcf!.sendRequest(for: route) { (success, error) in
			XCTAssertNil(error)
			XCTAssertTrue(success)
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func testSendRequestPUT() {
		let route = TestRoutable(path: "/posts", method: .put, header: nil, parameters: nil, body: ["title": "test", "body": "test", "userId": 1])
		
		let exp = expectation(description: "put request")
		gcf!.sendRequest(for: route) { (success, error) in
			XCTAssertNil(error)
			XCTAssertTrue(success)
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func testSendRequestParsingError() {
		let route = TestRoutable(path: "/posts", method: .post, header: nil, parameters: nil, body: nil)
		let exp = expectation(description: "post request")

		let observable: Observable<TestPost> = gcf!.sendRequest(for: route)
		observable.subscribe { (event) in
			switch event {
			case .next(_):
				XCTFail()
			case .error(_):
				exp.fulfill()
			case .completed:
				XCTFail()
			}
			}.disposed(by: disposeBag)
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func testSendRequestCompletion() {
		let route = TestRoutable(path: "/posts/1", method: .get, header: nil, parameters: nil, body: nil)
		
		let exp = expectation(description: "get request")
		gcf!.sendRequest(for: route) { (post: TestPost?, error) in
			XCTAssertNotNil(post)
			XCTAssertNil(error)
			XCTAssertTrue(post!.title.contains("sunt aut"))
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
}
