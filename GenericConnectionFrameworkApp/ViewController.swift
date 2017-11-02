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
	var headers: [String : String]?
	var parameters: [String : String]?
	var body: [String : Any]?
}

struct TestObject: Codable {
	var identifier: String
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let gcf = RxGCF(baseURL: "https://google.com")
		let test = TestRoute(path: "", method: .get, headers: nil, parameters: nil, body: nil)
		gcf.sendRequest(for: test) { (result: TestObject?, error) in
			if let error = error {
				
			}
		}
    }
}

