//
//  MockGCF.swift
//  GenericConnectionFrameworkTests
//
//  Created by Alan Downs on 8/30/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation
@testable import GenericConnectionFramework

open class MockGCF: GCF {
	
	public var remoteConfiguration: RemoteConfiguration?
	public var baseURL: String
	public var urlSession: URLSession
	public var decoder: JSONDecoder
	public var plugin: AggregatePlugin?
	
	public required init(configuration: RemoteConfiguration) {
		self.baseURL = configuration.baseURL
		urlSession = MockURLSession()
		self.decoder = JSONDecoder()
	}
	
	public required init(baseURL: String, decoder: JSONDecoder = JSONDecoder(), pinPublicKey: String? = nil) {
        guard !baseURL.isEmpty else { fatalError("invalid base url") }
		
        self.baseURL = baseURL
        urlSession = MockURLSession()
        self.decoder = JSONDecoder()
    }
	
	public func sendRequest<T>(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (T?, Error?) -> Void) where T : Decodable, T : Encodable {
		completion(nil, nil)
	}
	
	public func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (Bool, Error?) -> Void) {
		completion(false, nil)
	}
    
    public func sendRequest(for routable: Routable, numAuthRetries: Int, completion: @escaping ([String: Any]?, Error?) -> Void) {
        completion(nil, nil)
    }
	
	public func configurePlugins(_ plugins: [GCFPlugin]) {
		
	}
}
