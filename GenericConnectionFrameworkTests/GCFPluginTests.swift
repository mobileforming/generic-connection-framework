//
//  GCFPluginTests.swift
//  GenericConnectionFrameworkTests
//
//  Created by Alan Downs on 11/7/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import XCTest
@testable import GenericConnectionFramework

class GCFPluginTests: XCTestCase {
	
	var gcfPlugin: AggregatePlugin?
    
    override func setUp() {
        super.setUp()
		
    }
    
    override func tearDown() {
       gcfPlugin = nil
        super.tearDown()
    }
	
	func testInitPlugin() {
		gcfPlugin = AggregatePlugin(plugins: [MockGCFPlugin()])
		XCTAssertEqual(gcfPlugin!.plugins.count, 1)
		
		gcfPlugin = AggregatePlugin(plugins: [MockGCFPlugin(), MockGCFPlugin()])
		XCTAssertEqual(gcfPlugin!.plugins.count, 2)
	}
	
	func testWillSend() {
		gcfPlugin = AggregatePlugin(plugins: [MockGCFPlugin()])
		
		var request = URLRequest(url: URL(string: "http://google.com")!)
        let _ = gcfPlugin!.willSendRequest(&request, needsAuthorization: true)
		
		let plugin = gcfPlugin!.plugins.first! as! MockGCFPlugin
		XCTAssertEqual(plugin.willSendCalledCount, 1)
	}
	
	func testDidReceive() {
		gcfPlugin = AggregatePlugin(plugins: [MockGCFPlugin()])
		
		var request = URLRequest(url: URL(string: "http://google.com")!)
		let _ = gcfPlugin!.didReceive(data: nil, response: nil, error: nil, forRequest: &request)
		
		let plugin = gcfPlugin!.plugins.first! as! MockGCFPlugin
		XCTAssertEqual(plugin.didReceiveCalledCount, 1)
	}
    
    func testWillSendErrorContinueAbort() {
        let plugin1 = MockGCFPlugin()
        let plugin2 = MockGCFPlugin()
        plugin1.willSendError = GCFError.PluginError.failureContinue
        plugin2.willSendError = GCFError.PluginError.failureAbortRequest // should win
        
        gcfPlugin = AggregatePlugin(plugins: [plugin1, plugin2])
        var request = URLRequest(url: URL(string: "http://google.com")!)
        guard let error = gcfPlugin!.willSendRequest(&request, needsAuthorization: true) as? GCFError.PluginError else {
            XCTFail("wrong error type or no error returned")
            return
        }
        
        XCTAssertEqual(error, GCFError.PluginError.failureAbortRequest)
    }
    
    func testWillSendErrorAbortContinue() {
        let plugin1 = MockGCFPlugin()
        let plugin2 = MockGCFPlugin()
        plugin1.willSendError = GCFError.PluginError.failureAbortRequest // should win
        plugin2.willSendError = GCFError.PluginError.failureContinue
        
        gcfPlugin = AggregatePlugin(plugins: [plugin1, plugin2])
        var request = URLRequest(url: URL(string: "http://google.com")!)
        guard let error = gcfPlugin!.willSendRequest(&request, needsAuthorization: true) as? GCFError.PluginError else {
            XCTFail("wrong error type or no error returned")
            return
        }
        
        XCTAssertEqual(error, GCFError.PluginError.failureAbortRequest)
    }
    
    func testDidReceiveErrorContinueAbort() {
        let plugin1 = MockGCFPlugin()
        let plugin2 = MockGCFPlugin()
        plugin1.didReceiveError = GCFError.PluginError.failureContinue
        plugin2.didReceiveError = GCFError.PluginError.failureAbortRequest // should win
        
        gcfPlugin = AggregatePlugin(plugins: [plugin1, plugin2])
        var request = URLRequest(url: URL(string: "http://google.com")!)
        guard let error = gcfPlugin!.didReceive(data: Data(), response: nil, error: nil, forRequest: &request) as? GCFError.PluginError else {
            XCTFail("wrong error type or no error returned")
            return
        }
        
        XCTAssertEqual(error, GCFError.PluginError.failureAbortRequest)
    }
    
    func testDidReceiveErrorAbortContinue() {
        let plugin1 = MockGCFPlugin()
        let plugin2 = MockGCFPlugin()
        plugin1.didReceiveError = GCFError.PluginError.failureAbortRequest // should win
        plugin2.didReceiveError = GCFError.PluginError.failureContinue
        
        gcfPlugin = AggregatePlugin(plugins: [plugin1, plugin2])
        var request = URLRequest(url: URL(string: "http://google.com")!)
        guard let error = gcfPlugin!.didReceive(data: Data(), response: nil, error: nil, forRequest: &request) as? GCFError.PluginError else {
            XCTFail("wrong error type or no error returned")
            return
        }
        
        XCTAssertEqual(error, GCFError.PluginError.failureAbortRequest)
    }
}
