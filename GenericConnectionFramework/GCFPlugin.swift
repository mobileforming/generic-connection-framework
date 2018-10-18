//
//  GCFPlugin.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 8/29/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation

public protocol GCFPlugin {
    func willSendRequest(_ request: inout URLRequest, needsAuthorization: Bool) -> Error?
	func didReceive(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) -> Error?
}

class AggregatePlugin: GCFPlugin {
	var plugins: [GCFPlugin]
	
	required init(plugins: [GCFPlugin]) {
		self.plugins = plugins
	}
	
	func willSendRequest(_ request: inout URLRequest, needsAuthorization: Bool) -> Error? {
		for plugin in plugins {
            if let error = plugin.willSendRequest(&request, needsAuthorization: needsAuthorization) {
                switch error {
                case GCFError.PluginError.failureContinue:
                    break
                default:
                    return error
                }
            }
        }
        return nil
	}
	
	func didReceive(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) -> Error? {
		for plugin in plugins.reversed() {
            if let error = plugin.didReceive(data: data, response: response, error: error, forRequest: &request) {
                switch error {
                case GCFError.PluginError.failureContinue:
                    break
                default:
                    return error
                }
            }
        }
        return nil
	}
}
