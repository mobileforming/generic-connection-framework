//
//  MockGCF.swift
//  GenericConnectionFrameworkTests
//
//  Created by Alan Downs on 8/30/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation
import RxSwift
@testable import GenericConnectionFramework

open class MockGCF: GCF {
	
	public var baseURL: String
	public var urlSession: URLSession
	public var decoder: JSONDecoder
	public var plugin: GCFPlugin?
	
	public required init(baseURL: String, decoder: JSONDecoder = JSONDecoder()) {
        guard !baseURL.isEmpty else { fatalError("invalid base url") }
        
        self.baseURL = baseURL
        urlSession = MockURLSession()
        self.decoder = JSONDecoder()
    }
    
    public func sendRequest<T: Codable>(for routable: Routable) -> Observable<T> {
        return Observable.create({ (observer) -> Disposable in
            return Disposables.create()
        })
    }
    
    public func sendRequest<T: Codable>(for routable: Routable, completion: @escaping (T?, Error?) -> Void) {
        completion(nil, nil)
    }
	
	public func sendRequest(for routable: Routable, completion: @escaping (Bool, Error?) -> Void) {
		completion(false, nil)
	}
	
	public func configurePlugin(_ plugin: GCFPlugin) {
		
	}
	
	public func configurePlugins(_ plugins: [GCFPlugin]) {
		
	}
}
