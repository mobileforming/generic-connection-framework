//
//  MockURLSession.swift
//  GenericConnectionFrameworkTests
//
//  Created by Alan Downs on 8/30/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation

enum MockURLSessionError: Error {
	case failure
}

class MockURLSession: URLSession {
	
	var failRequest = false
	
	override func dataTask(with: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) -> MockURLSessionDataTask {
		let dataTask = MockURLSessionDataTask(failRequest: failRequest, completionHandler: completionHandler)
		return dataTask
	}
}

class MockURLSessionDataTask: URLSessionDataTask {
	
	var failRequest = false
	var completionHandler: (Data?, URLResponse?, Error?) -> ()
	
	init(failRequest: Bool, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
		self.failRequest = failRequest
		self.completionHandler = completionHandler
	}
	
	override func resume() {
		if failRequest {
			completionHandler(nil, nil, MockURLSessionError.failure)
		} else {
			let testDictionary = ["test": "test"]
			let testData = try! JSONSerialization.data(withJSONObject: testDictionary, options: [])
			completionHandler(testData, URLResponse(), nil)
		}
	}
}
