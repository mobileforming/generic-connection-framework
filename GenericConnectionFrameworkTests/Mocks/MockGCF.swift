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
	
	public required init(baseURL: String) {
		guard !baseURL.isEmpty else { fatalError("invalid base url") }
		
		self.baseURL = baseURL
		urlSession = MockURLSession()
		decoder = JSONDecoder()
	}
	
	public func sendRequest<T>(for routable: Routable) -> Observable<T> where T : Decodable {
		return Observable.create({ (observer) -> Disposable in
			return Disposables.create()
		})
	}
	
	public func sendRequest<T>(for routable: Routable, completion: @escaping (T?, Error?) -> Void) where T : Decodable {
		completion(nil, nil)
	}
}
