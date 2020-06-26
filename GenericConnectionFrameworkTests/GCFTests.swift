//
//  GCFTests.swift
//  GenericConnectionFrameworkTests
//
//  Created by Alan Downs on 8/30/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import XCTest
@testable import GenericConnectionFramework

class GCFTests: XCTestCase {
	
	struct TestRoutable: Routable {
		var path: String
		var method: HTTPMethod
		var headers: [String:String]?
		var parameters: [String:String]?
		var body: [String:AnyHashable]?
        var bodyData: RoutableBodyData = .none
		var needsAuthorization: Bool
		var defaultTimeout: TimeInterval
	}
	
	struct TestObject: Codable {
		var identifier: String
	}
	
	var gcf: MockGCF?
	
    override func setUp() {
        super.setUp()
		gcf = MockGCF(baseURL: "https://google.com")
    }
	
    override func tearDown() {
        gcf = nil
        super.tearDown()
    }
	
	func testConstructURLNoParams() {
		let routable = TestRoutable(path: "/noparams", method: .get, headers: nil, parameters: nil, body: nil, needsAuthorization: false, defaultTimeout: 100)
		let url = gcf!.constructURL(from: routable)
		
		XCTAssertTrue(url.absoluteString.contains(gcf!.baseURL))
		XCTAssertTrue(url.absoluteString.contains(routable.path))
		XCTAssertFalse(url.absoluteString.contains("?"))
		XCTAssertFalse(url.absoluteString.contains("&"))
	}
	
	func testConstructURLNilParams() {
		let routable = TestRoutable(path: "/noparams", method: .get, headers: nil, parameters: [:], body: nil, needsAuthorization: false, defaultTimeout: 100)
		let url = gcf!.constructURL(from: routable)
		
		XCTAssertTrue(url.absoluteString.contains(gcf!.baseURL))
		XCTAssertTrue(url.absoluteString.contains(routable.path))
		XCTAssertFalse(url.absoluteString.contains("?"))
		XCTAssertFalse(url.absoluteString.contains("&"))
	}
	
	func testConstructURLSingleParam() {
		let routable = TestRoutable(path: "/singleparam,", method: .get, headers: nil, parameters: ["test":"true"], body: nil, needsAuthorization: false, defaultTimeout: 100)
		let url = gcf!.constructURL(from: routable)
		
		XCTAssertTrue(url.absoluteString.contains(gcf!.baseURL))
		XCTAssertTrue(url.absoluteString.contains(routable.path))
		XCTAssertTrue(url.absoluteString.contains("?"))
		XCTAssertTrue(url.absoluteString.contains("test=true"))
		XCTAssertFalse(url.absoluteString.contains("&"))
	}
	
	func testConstructURLMultipleParams() {
		let routable = TestRoutable(path: "/multipleparams,", method: .get, headers: nil, parameters: ["test": "true", "test2": "false"], body: nil, needsAuthorization: false, defaultTimeout: 100)
		let url = gcf!.constructURL(from: routable)
		
		XCTAssertTrue(url.absoluteString.contains(gcf!.baseURL))
		XCTAssertTrue(url.absoluteString.contains(routable.path))
		XCTAssertTrue(url.absoluteString.contains("?"))
		XCTAssertTrue(url.absoluteString.contains("test=true&test2=false"))
	}
    
    func testConstructURLRequestWithBody() {
        let routable = TestRoutable(path: "/withbodypost", method: .post, headers: nil, parameters: nil, body: ["test": "test"], needsAuthorization: false, defaultTimeout: 100)
        let request = gcf!.constructURLRequest(from: routable)
        
        XCTAssertEqual(request.httpMethod, HTTPMethod.post.rawValue)
        XCTAssertNotNil(request.httpBody)
    }
    
    func testConstructURLRequestWithBodyGET() {
        let routable = TestRoutable(path: "/withbodyget", method: .get, headers: nil, parameters: nil, body: ["test": "test"], needsAuthorization: false, defaultTimeout: 100)
        let request = gcf!.constructURLRequest(from: routable)
        
        XCTAssertEqual(request.httpMethod, HTTPMethod.get.rawValue)
        XCTAssertNil(request.httpBody)
    }
    
    func testConstructURLRequestBodyDataNone() {
        let routable = TestRoutable(path: "/bodydatanone", method: .get, headers: nil, parameters: nil, body: nil, bodyData: .none, needsAuthorization: false, defaultTimeout: 100)
        let request = gcf!.constructURLRequest(from: routable)
        
        XCTAssertEqual(request.httpMethod, HTTPMethod.get.rawValue)
        XCTAssertNil(request.httpBody)
    }
    
    func testConstructURLRequestBodyDataJSONObjectPOST() {
        let routable = TestRoutable(path: "/bodydatajsonobject", method: .post, headers: nil, parameters: nil, body: nil, bodyData: .jsonObject(["test": "test"]), needsAuthorization: false, defaultTimeout: 100)
        let request = gcf!.constructURLRequest(from: routable)

        XCTAssertEqual(request.httpMethod, HTTPMethod.post.rawValue)
        XCTAssertNotNil(request.httpBody)
    }
    
    func testConstructURLRequestBodyDataJSONObjectGET() {
        let routable = TestRoutable(path: "/bodydatajsonobject", method: .get, headers: nil, parameters: nil, body: nil, bodyData: .jsonObject(["test": "test"]), needsAuthorization: false, defaultTimeout: 100)
        let request = gcf!.constructURLRequest(from: routable)

        XCTAssertEqual(request.httpMethod, HTTPMethod.get.rawValue)
        XCTAssertNil(request.httpBody)
    }
        
    func testConstructURLRequestBodyDataJSONArrayPOST() {
        let routable = TestRoutable(path: "/bodydatajsonobject", method: .post, headers: nil, parameters: nil, body: nil, bodyData: .jsonArray([["test": "test"], ["test": "test"]]), needsAuthorization: false, defaultTimeout: 100)
        let request = gcf!.constructURLRequest(from: routable)

        XCTAssertEqual(request.httpMethod, HTTPMethod.post.rawValue)
        XCTAssertNotNil(request.httpBody)
    }
	
	func testDefaultTimeout() {
		let routable = TestRoutable(path: "/timeout", method: .get, headers: nil, parameters: nil, body: nil, needsAuthorization: false, defaultTimeout: 33)
		let request = gcf!.constructURLRequest(from: routable)
		
		XCTAssertEqual(request.timeoutInterval, routable.defaultTimeout)
	}
	
	func testParseDataEmpty() {
		do {
			let _ : TestObject = try gcf!.parseData(from: Data())
			XCTFail("should not proceed to this point")
		} catch {
			print("expected")
		}
	}
	
	func testParseDataCorrupted() {
		let testData = Data([1, 2, 3, 4, 5])

		do {
			let _ : TestObject = try gcf!.parseData(from: testData)
			XCTFail("should not proceed to this point")
		} catch {
			print("expected")
		}
	}
	
	func testParseDataMissingKey() {
		let testValues = ["test": "test"]
		let testData = try! JSONSerialization.data(withJSONObject: testValues, options: [])
		
		do {
			let _ : TestObject = try gcf!.parseData(from: testData)
			XCTFail("should not proceed to this point")
		} catch {
			print("expected")
		}
	}
	
	func testParseDataTypeMismatch() {
		let testValues = [["test": "test"]]
		let testData = try! JSONSerialization.data(withJSONObject: testValues, options: [])
		
		do {
			let _ : TestObject = try gcf!.parseData(from: testData)
			XCTFail("should not proceed to this point")
		} catch {
			print("expected")
		}
	}
	
	func testParseData() {
		let testValues = ["identifier": "test"]
		let testData = try! JSONSerialization.data(withJSONObject: testValues, options: [])
		
		do {
			let results: TestObject = try gcf!.parseData(from: testData)
			XCTAssertEqual(results.identifier, "test")
		} catch {
			XCTFail("should not proceed to this point")
		}
	}
}
