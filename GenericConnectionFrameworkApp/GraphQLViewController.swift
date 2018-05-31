//
//  GraphQLViewController.swift
//  GenericConnectionFrameworkApp
//
//  Created by Alan Downs on 5/22/18.
//  Copyright © 2018 mobileforming LLC. All rights reserved.
//

import UIKit
import GenericConnectionFramework

struct StaysGraphRoute: GraphRoutable {
	var query: String
	var variables: [String:Any]?
	var path: String
	var method: HTTPMethod
	var headers: [String:String]?
	var parameters: [String:String]?
	var needsAuthorization: Bool
}

class GraphQLViewController: UIViewController {
	
	let query = """
query getStays($guestId: BigInt!) {
	guest(guestId: $guestId, language: "en") {
		upcomingStays {
			stayId
			gnrNumber
			confNumber
			arrivalDate
			departureDate
			hotel {
				ctyhocn
				brandCode
				displayCoe
				name
				phoneNumber
				address {
					addressFmt
				}
				coordinate {
					latitude
					longitude
				}
				thumbImage {
					hiResSrc
				}
			}
		}
	}
}
"""
	
	let gcf = APIClient(baseURL: "https://api-t.hilton.io")

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let route = StaysGraphRoute(query: query, variables: ["guestId": 1516564425], path: "/v2/graphql/customer", method: .post, headers: ["Content-Type": "application/json"], parameters: nil, needsAuthorization: false)
		
		gcf.sendRequest(for: route) { (success, error) in
			print(error?.localizedDescription ?? "")
		}
    }
}
