//
//  MockRoutable.swift
//  GenericConnectionFrameworkTests
//
//  Created by Wesley St. John on 10/17/18.
//  Copyright © 2018 mobileforming LLC. All rights reserved.
//

import Foundation
import GenericConnectionFramework

struct MockRoutable: Routable {
    var path: String { return "" }
    
    var method: HTTPMethod { return .get }
    
    var headers: [String : String]? { return nil }
    
    var parameters: [String : String]? { return nil }
    
    var body: [String : Any]? { return nil}
    
    var needsAuthorization: Bool { return false }
    
}
