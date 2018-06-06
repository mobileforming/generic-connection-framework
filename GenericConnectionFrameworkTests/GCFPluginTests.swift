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
        gcfPlugin!.willSendRequest(&request, needsAuthorization: true)
		
		let plugin = gcfPlugin!.plugins.first! as! MockGCFPlugin
		XCTAssertEqual(plugin.willSendCalledCount, 1)
	}
	
	func testDidReceive() {
		gcfPlugin = AggregatePlugin(plugins: [MockGCFPlugin()])
		
		var request = URLRequest(url: URL(string: "http://google.com")!)
		try! gcfPlugin!.didReceive(data: nil, response: nil, error: nil, forRequest: &request)
		
		let plugin = gcfPlugin!.plugins.first! as! MockGCFPlugin
		XCTAssertEqual(plugin.didReceiveCalledCount, 1)
	}
}
