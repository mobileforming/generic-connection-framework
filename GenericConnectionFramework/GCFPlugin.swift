//
//  GCFPlugin.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 8/29/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation

public protocol GCFPlugin {
    func willSendRequest(_ request: inout URLRequest, needsAuthorization: Bool)
	func didReceive(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) throws
}

class AggregatePlugin: GCFPlugin {
	var plugins: [GCFPlugin]
	
	required init(plugins: [GCFPlugin]) {
		self.plugins = plugins
	}
	
	func willSendRequest(_ request: inout URLRequest, needsAuthorization: Bool) {
		plugins.forEach({ $0.willSendRequest(&request, needsAuthorization: needsAuthorization) })
	}
	
	func didReceive(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) throws {
		try plugins.reversed().forEach({ try $0.didReceive(data: data, response: response, error: error, forRequest: &request) })
	}
}
