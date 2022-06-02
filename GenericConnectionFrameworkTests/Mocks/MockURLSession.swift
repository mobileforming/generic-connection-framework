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

protocol MockURLSessionDelegate {
    func didResumeTask(_ task: MockURLSessionDataTask)
}

class MockURLSession: URLSession, MockURLSessionDelegate {
	
	var failRequest = false
    var dataTaskCount = 0
    
    override init() {
        // This should block the warning of it being deprecated.
    }
    
	override func dataTask(with: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) -> MockURLSessionDataTask {
		let dataTask = MockURLSessionDataTask(failRequest: failRequest, completionHandler: completionHandler)
        dataTask.delegate = self
		return dataTask
	}
    
    func didResumeTask(_ task: MockURLSessionDataTask) {
        dataTaskCount += 1
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
	
    var delegate: MockURLSessionDelegate?
	var failRequest = false
	var completionHandler: (Data?, URLResponse?, Error?) -> ()
	
	init(failRequest: Bool, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
		self.failRequest = failRequest
		self.completionHandler = completionHandler
	}
	
	override func resume() {
        
        delegate?.didResumeTask(self)
        
		if failRequest {
			completionHandler(nil, nil, MockURLSessionError.failure)
		} else {
			let testDictionary = ["test": "test"]
			let testData = try! JSONSerialization.data(withJSONObject: testDictionary, options: [])
			completionHandler(testData, URLResponse(), nil)
		}
	}
}
