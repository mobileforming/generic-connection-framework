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
	
	func testKey() {
        var routable = MockRoutable()
        routable.path = "/some/arbitrary/path"
        routable.headers = ["header1": "value1", "header2": "value2"]
        routable.parameters = ["parameter1": "value1", "parameter2": "value2"]
        routable.body = ["key1": "value1", "key2": "value2", "key3": "value3"]
        
        let routableHash = "/some/arbitrary/path".hashValue
                        &+ HTTPMethod.get.hashValue
                        &+ ["parameter1": "value1", "parameter2": "value2"].hashValue
                        &+ ["key1": "value1", "key2": "value2", "key3": "value3"].hashValue
        
        let key = completionQueue.key(for: routable, numAuthRetries: 99, completionType: [String:Any].self)
        let expectedKey = "\(routableHash &+ 99):Dictionary<String, Any>"
        
        XCTAssertEqual(key, expectedKey)
	}
	
    
    // MARK - Codable
    
	func testShouldRequestContinueCodable() {
        let routable = MockRoutable()
		var completed = 0
		let completion: (ResponseHeader?, EmptyCodable?, Error?) -> Void = { (_, result, error) in
			completed += 1
		}

		let firstResult = completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
		XCTAssertTrue(firstResult)
		XCTAssertEqual(completed, 0)
		
		let secondResult = completionQueue.shouldRequestContinue(forKey: completionQueue.key(for: routable, numAuthRetries: 99, completionType: EmptyCodable.self), completion: completion)
		XCTAssertFalse(secondResult)
		XCTAssertEqual(completed, 0)
		
		let exp = expectation(description: "")
		let group = DispatchGroup()
		for _ in 0...10 {
			group.enter()
			DispatchQueue.global().async {
				let testResult = self.completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
				XCTAssertFalse(testResult)
				XCTAssertEqual(completed, 0)
				group.leave()
			}
		}
		group.notify(queue: .main) { exp.fulfill() }
		waitForExpectations(timeout: 10, handler: nil)
		
		XCTAssertEqual(completed, 0)
	}
	
	func testProcessCompletionsCodable() {
		let routable = MockRoutable()
		var completed = 0
		let completion: (ResponseHeader?, EmptyCodable?, Error?) -> Void = { (_, result, error) in
			completed += 1
		}
		
		//add in the first
		let firstResult = completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
		XCTAssertTrue(firstResult)
		XCTAssertEqual(completed, 0)
		
		//add in 9 more
		let exp = expectation(description: "")
		let group = DispatchGroup()
		for _ in 1...9 {
			group.enter()
			DispatchQueue.global().async {
				let testResult = self.completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
				XCTAssertFalse(testResult)
				XCTAssertEqual(completed, 0)
				group.leave()
			}
		}
		group.notify(queue: .main) { exp.fulfill() }
		waitForExpectations(timeout: 10, handler: nil)
		
        completionQueue.processCompletions(forRoutable: routable, response: nil, numAuthRetries: 99, result: EmptyCodable(), error: nil)
		let waitExp = expectation(description: "")
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			waitExp.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
		
		XCTAssertEqual(completed, 10)
		
		
		//check new request, queue is empty
		let result = completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
		XCTAssertTrue(result)
	}
    
    
    // MARK - Bool
    
    func testShouldRequestContinueBool() {
        let routable = MockRoutable()
        var completed = 0
        let completion: (ResponseHeader?, Bool?, Error?) -> Void = { (_, result, error) in
            completed += 1
        }
        
        let firstResult = completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
        XCTAssertTrue(firstResult)
        XCTAssertEqual(completed, 0)
        
        let secondResult = completionQueue.shouldRequestContinue(forKey: completionQueue.key(for: routable, numAuthRetries: 99, completionType: Bool.self), completion: completion)
        XCTAssertFalse(secondResult)
        XCTAssertEqual(completed, 0)
        
        let exp = expectation(description: "")
        let group = DispatchGroup()
        for _ in 0...10 {
            group.enter()
            DispatchQueue.global().async {
                let testResult = self.completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
                XCTAssertFalse(testResult)
                XCTAssertEqual(completed, 0)
                group.leave()
            }
        }
        group.notify(queue: .main) { exp.fulfill() }
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertEqual(completed, 0)
    }
    
    func testProcessCompletionsBool() {
        let routable = MockRoutable()
        var completed = 0
        let completion: (ResponseHeader?, Bool?, Error?) -> Void = { (_, result, error) in
            completed += 1
        }
        
        //add in the first
        let firstResult = completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
        XCTAssertTrue(firstResult)
        XCTAssertEqual(completed, 0)
        
        //add in 9 more
        let exp = expectation(description: "")
        let group = DispatchGroup()
        for _ in 1...9 {
            group.enter()
            DispatchQueue.global().async {
                let testResult = self.completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
                XCTAssertFalse(testResult)
                XCTAssertEqual(completed, 0)
                group.leave()
            }
        }
        group.notify(queue: .main) { exp.fulfill() }
        waitForExpectations(timeout: 10, handler: nil)
        
        completionQueue.processCompletions(forRoutable: routable, response: nil, numAuthRetries: 99, result: true as Bool?, error: nil)
        let waitExp = expectation(description: "")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            waitExp.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertEqual(completed, 10)
        
        
        //check new request, queue is empty
        let result = completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
        XCTAssertTrue(result)
    }
    
    
    // MARK - Dictionary
    
    func testShouldRequestContinueDictionary() {
        let routable = MockRoutable()
        var completed = 0
        let completion: (ResponseHeader?, [String: Any]?, Error?) -> Void = { (_, result, error) in
            completed += 1
        }
        
        let firstResult = completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
        XCTAssertTrue(firstResult)
        XCTAssertEqual(completed, 0)
        
        let secondResult = completionQueue.shouldRequestContinue(forKey: completionQueue.key(for: routable, numAuthRetries: 99, completionType: [String:Any].self), completion: completion)
        XCTAssertFalse(secondResult)
        XCTAssertEqual(completed, 0)
        
        let exp = expectation(description: "")
        let group = DispatchGroup()
        for _ in 0...10 {
            group.enter()
            DispatchQueue.global().async {
                let testResult = self.completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
                XCTAssertFalse(testResult)
                XCTAssertEqual(completed, 0)
                group.leave()
            }
        }
        group.notify(queue: .main) { exp.fulfill() }
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertEqual(completed, 0)
    }
    
    func testProcessCompletionsDictionary() {
        let routable = MockRoutable()
        var completed = 0
        let completion: (ResponseHeader?, [String: Any]?, Error?) -> Void = { (_, result, error) in
            completed += 1
        }
        
        //add in the first
        let firstResult = completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
        XCTAssertTrue(firstResult)
        XCTAssertEqual(completed, 0)
        
        //add in 9 more
        let exp = expectation(description: "")
        let group = DispatchGroup()
        for _ in 1...9 {
            group.enter()
            DispatchQueue.global().async {
                let testResult = self.completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
                XCTAssertFalse(testResult)
                XCTAssertEqual(completed, 0)
                group.leave()
            }
        }
        group.notify(queue: .main) { exp.fulfill() }
        waitForExpectations(timeout: 10, handler: nil)
        
        completionQueue.processCompletions(forRoutable: routable, response: nil, numAuthRetries: 99, result: ["hello": "goodbye"] as [String: Any]?, error: nil)
        let waitExp = expectation(description: "")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            waitExp.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertEqual(completed, 10)
        
        
        //check new request, queue is empty
        let result = completionQueue.shouldRequestContinue(forRoutable: routable, numAuthRetries: 99, completion: completion)
        XCTAssertTrue(result)
    }
}

struct EmptyCodable: Codable {}
