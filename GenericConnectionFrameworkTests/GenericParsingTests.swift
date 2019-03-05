//
//  GenericParsingTests.swift
//  GenericConnectionFrameworkTests
//
//  Created by Christopher Spradling on 3/4/19.
//  Copyright © 2019 mobileforming LLC. All rights reserved.
//

import Foundation
import XCTest
@testable import GenericConnectionFramework

struct SampleCodable: Codable {
    var foo: String
}

class GenericParsingTests: XCTestCase {
    
    let gcf = MockGCF(baseURL: "www.my.homepage.geocities.com.gov/angelfire/yahoo.org.co.uk.wordpress.biz")
    
    let testKey = "foo"
    let testValue = "bar"
    
    var sampleJSON: [String:Any] = [:]
    
    var data: Data?
    
    override func setUp() {
        super.setUp()
        
        sampleJSON = [testKey: testValue]
        
        do {
            data = try JSONSerialization.data(withJSONObject: sampleJSON, options: [])
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testData() {
        do {
            
            let parsed: Data = try gcf.parseData(from: data)
            
            XCTAssertEqual(data, parsed)
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        do {
            let _: Data = try gcf.parseData(from: nil)
            
            XCTFail("failed to throw" )
        } catch let error {
            XCTAssertTrue(error is GCFError)
        }
        
    }
    
    func testBool() {
        do {
            
            let parsed: Bool = try gcf.parseData(from: data)
            
            XCTAssertTrue(parsed)
            
            let parsedNil: Bool = try gcf.parseData(from: nil)
            
            XCTAssertFalse(parsedNil)
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }

    }
    
    func testDictionary() {
        do {
            
            let parsed: [String:Any] = try gcf.parseData(from: data)
            
            XCTAssertNotNil(parsed)
            XCTAssertEqual(parsed[testKey] as? String, testValue)
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        do {
            let _: [String:Any] = try gcf.parseData(from: nil)
            
            XCTFail("failed to throw" )
        } catch let error {
            XCTAssertTrue(error is GCFError)
        }

    }
    
    func testDecodable() {
        do {
            
            let parsed: SampleCodable = try gcf.parseData(from: data)
            
            XCTAssertEqual(parsed.foo, testValue)
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        do {
            let _: SampleCodable = try gcf.parseData(from: nil)
            
            XCTFail("failed to throw" )
        } catch let error {
            XCTAssertTrue(error is GCFError)
        }

    }
    
    func testOptionalData() {
        do {
            
            let parsed: Data? = try gcf.parseData(from: data)
            
            XCTAssertEqual(parsed, data)
            
            let parsedWithNil: Data? = try gcf.parseData(from: nil)
            
            XCTAssertNil(parsedWithNil) // more importantly, we didn't throw if we got here
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
    }
    
    func testOptionalBool() {
        do {
            
            let parsed: Bool? = try gcf.parseData(from: data)
            
            XCTAssertEqual(parsed, true)
            
            let parsedWithNil: Bool? = try gcf.parseData(from: nil)
            
            XCTAssertNotNil(parsedWithNil)
            XCTAssertFalse(parsedWithNil ?? true)
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
    }
    
    func testOptionalDictionary() {
        do {
            
            let parsed: [String:Any]? = try gcf.parseData(from: data)
            
            XCTAssertEqual(parsed?[testKey] as? String, testValue)
            
            let parsedWithNil: [String:Any]? = try gcf.parseData(from: nil)
            
            XCTAssertNil(parsedWithNil)
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
    }
    
    func testOptionalDecodable() {
        do {
            
            let parsed: SampleCodable? = try gcf.parseData(from: data)
            
            XCTAssertEqual(parsed?.foo, testValue)
            
            let parsedWithNil: SampleCodable? = try gcf.parseData(from: nil)
            
            XCTAssertNil(parsedWithNil)
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
    }
    
}
