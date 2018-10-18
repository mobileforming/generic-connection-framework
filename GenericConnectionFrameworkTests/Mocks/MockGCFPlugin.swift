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
    var willSendError: Error?
    var didReceiveError: Error?
	
	func willSendRequest(_ request: inout URLRequest, needsAuthorization: Bool) -> Error? {
		willSendCalledCount += 1
        return willSendError
	}
	
	func didReceive(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) -> Error? {
		didReceiveCalledCount += 1
        return didReceiveError
	}
}
