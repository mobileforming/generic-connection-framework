//
//  ViewController.swift
//  GenericConnectionFrameworkApp
//
//  Created by Wesley St. John on 7/27/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import UIKit
import GenericConnectionFramework

struct TestRoute: Routable {
	var path: String
	var method: HTTPMethod
	var headers: [String:String]?
	var parameters: [String:String]?
	var body: [String:Any]?
	var needsAuthorization: Bool
}

struct Product: Codable {
	var productId: String
	var name: String
	var price: Int
	
	enum CodingKeys: String, CodingKey {
		case productId = "id"
		case name
		case price
	}
}

class ViewController: UIViewController {
	
	let gcf = APIClient(baseURL: "http://172.33.22.42:9000/api/poc/square/products")

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let vend = TestRoute(path: "", method: .get, headers: nil, parameters: nil, body: nil, needsAuthorization: false)
		gcf.sendRequest(for: vend) { (result: [Product]?, error) in
			print(result)
		}
    }
}

