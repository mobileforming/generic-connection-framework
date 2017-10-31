//
//  GCFPlugin.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 8/29/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation

public enum GCFPluginError: Error {
	case failureAbortRequest		//fail entire request
	case failureCompleteRequest		//don't process remaining plugins, finish the request
	case failureContinue			//continue with remaining plugins
}

public protocol GCFPlugin {
	func willSendRequest(_ request: inout URLRequest)
	func didRecieve(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) throws
}

class AggregatePlugin: GCFPlugin {
	var plugins: [GCFPlugin]
	
	required init(plugins: [GCFPlugin]) {
		self.plugins = plugins
	}
	
	func willSendRequest(_ request: inout URLRequest) {
		plugins.forEach({ $0.willSendRequest(&request) })
	}
	
	func didRecieve(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) throws {
		try plugins.reversed().forEach({ try $0.didRecieve(data: data, response: response, error: error, forRequest: &request) })
	}
}
