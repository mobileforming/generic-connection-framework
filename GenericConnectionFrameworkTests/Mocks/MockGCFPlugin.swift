//
//  MockGCFPlugin.swift
//  GenericConnectionFrameworkTests
//
//  Created by Alan Downs on 11/7/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation
@testable import GenericConnectionFramework

class MockGCFPlugin: GCFPlugin {
	var willSendCalledCount = 0
	var didReceiveCalledCount = 0
	
	func willSendRequest(_ request: inout URLRequest) {
		willSendCalledCount += 1
	}
	
	func didReceive(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) throws {
		didReceiveCalledCount += 1
	}
}
