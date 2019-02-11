//
//  CompletionQueueTests.swift
//  GenericConnectionFrameworkTests
//
//  Created by Alan Downs on 2/11/19.
//  Copyright © 2019 mobileforming LLC. All rights reserved.
//

import XCTest
@testable import GenericConnectionFramework

class CompletionQueueTests: XCTestCase {
	
	var completionQueue: CompletionQueue!

    override func setUp() {
        completionQueue = CompletionQueue()
    }

    override func tearDown() {
        completionQueue = nil
    }

//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
	
	func testKey() {
		let request = URLRequest(url: URL(string: "https://google.com")!)
		XCTAssertEqual(completionQueue.key(for: request, numAuthRetries: 99), "\(request.hashValue + 99)")
	}
	
	func testShouldRequestContinue() {
		let request = URLRequest(url: URL(string: "https://google.com")!)
		var completed = 0
		let completion: (MockCodable?, Error?) -> Void = { (result, error) in
			completed += 1
		}

		let firstResult = completionQueue.shouldRequestContinue(forRequest: request, numAuthRetries: 99, completion: completion)
		XCTAssertTrue(firstResult)
		XCTAssertEqual(completed, 0)
		
		let secondResult = completionQueue.shouldRequestContinue(forKey: completionQueue.key(for: request, numAuthRetries: 99), completion: completion)
		XCTAssertFalse(secondResult)
		XCTAssertEqual(completed, 0)
		
		let exp = expectation(description: "")
		let group = DispatchGroup()
		for _ in 0...10 {
			group.enter()
			DispatchQueue.global().async {
				let testResult = self.completionQueue.shouldRequestContinue(forRequest: request, numAuthRetries: 99, completion: completion)
				XCTAssertFalse(testResult)
				XCTAssertEqual(completed, 0)
				group.leave()
			}
		}
		group.notify(queue: .main) { exp.fulfill() }
		waitForExpectations(timeout: 10, handler: nil)
		
		XCTAssertEqual(completed, 0)
	}
	
	func testProcessCompletions() {
		let request = URLRequest(url: URL(string: "https://google.com")!)
		var completed = 0
		let completion: (MockCodable?, Error?) -> Void = { (result, error) in
			completed += 1
		}
		
		//add in the first
		let firstResult = completionQueue.shouldRequestContinue(forRequest: request, numAuthRetries: 99, completion: completion)
		XCTAssertTrue(firstResult)
		XCTAssertEqual(completed, 0)
		
		//add in 9 more
		let exp = expectation(description: "")
		let group = DispatchGroup()
		for _ in 1...9 {
			group.enter()
			DispatchQueue.global().async {
				let testResult = self.completionQueue.shouldRequestContinue(forRequest: request, numAuthRetries: 99, completion: completion)
				XCTAssertFalse(testResult)
				XCTAssertEqual(completed, 0)
				group.leave()
			}
		}
		group.notify(queue: .main) { exp.fulfill() }
		waitForExpectations(timeout: 10, handler: nil)
		
		completionQueue.processCompletions(forRequest: request, numAuthRetries: 99, result: MockCodable(), error: nil)
		let waitExp = expectation(description: "")
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			waitExp.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
		
		XCTAssertEqual(completed, 10)
		
		
		//check new request, queue is empty
		let result = completionQueue.shouldRequestContinue(forRequest: request, numAuthRetries: 99, completion: completion)
		XCTAssertTrue(result)
	}
}

struct MockCodable: Codable {}
