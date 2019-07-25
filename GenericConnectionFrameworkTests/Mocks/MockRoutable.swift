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
    var path = ""
    var method: HTTPMethod = .get
    var headers: [String : String]?
    var parameters: [String : String]?
    var body: [String : AnyHashable]?
    var needsAuthorization = false
}
