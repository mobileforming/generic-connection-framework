//
//  HashableRoutable.swift
//  GenericConnectionFramework
//
//  Created by Wesley St. John on 10/11/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation

struct HashableRoutable: Routable, Hashable {
    fileprivate let routable: Routable
    fileprivate let hashClosure: () -> Int
    fileprivate let equalClosure: (Any) -> Bool
    
    var hashValue: Int {
        return hashClosure()
    }
    
    var path: String { return routable.path }
    var method: HTTPMethod { return routable.method }
    var headers: [String : String]? { return routable.headers }
    var parameters: [String : String]? { return routable.parameters }
    var body: [String : Any]? { return routable.body }
    
    init<T: Routable>(routable: T) {
        self.routable = routable
        hashClosure = { return routable.path.hashValue }
        equalClosure = { if let other = $0 as? T { return routable == other } else { return false } }
    }
}

func == (lhs: Routable, rhs: Routable) -> Bool {
    return lhs.path == rhs.path
}

func == (left: HashableRoutable, right: HashableRoutable) -> Bool {
    return left.equalClosure(right.routable)
}

