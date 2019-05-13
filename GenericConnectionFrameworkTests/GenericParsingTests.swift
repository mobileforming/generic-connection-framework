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

struct CodableThatWillFail: Codable {
    var somethingDifferent: Int
}

struct NotCodable {
    var whatever: CGRect
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
            XCTAssertTrue(error is GCFError.ParsingError)
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
            XCTAssertTrue(error is GCFError.ParsingError)
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
            XCTAssertTrue(error is GCFError.ParsingError)
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

            let wrongDecodable: CodableThatWillFail? = try gcf.parseData(from: data)
            
            XCTAssertNil(wrongDecodable)
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
    }
    
    func testWrongCodableThrowsDecodingErrorWhenNonOptional() {
        
        do {
            
            let _: CodableThatWillFail = try gcf.parseData(from: data)
            
            XCTFail("should have thrown an error")
            
        } catch let error {
            
            guard
                case GCFError.ParsingError.codable(let decodingError?) = error,
                case .keyNotFound(let codingPath, let context) = decodingError
            else {
                XCTFail("wrong error was thrown: \(error.localizedDescription)")
                return
            }
            
            XCTAssertEqual(codingPath.stringValue, "somethingDifferent")
            XCTAssertEqual(context.debugDescription, "No value associated with key CodingKeys(stringValue: \"somethingDifferent\", intValue: nil) (\"somethingDifferent\").")
            
        }
        
    }
    
    func testDictionaryThrowsCorrectErrorWhenNonOptional() {
        
        do {
            
            let _: [String:Any] = try gcf.parseData(from: Data())
            
            XCTFail("should have thrown an error")
            
        } catch let error {
            
            guard
                case GCFError.ParsingError.jsonSerialization(let jsonError?) = error
                else {
                    XCTFail("wrong error was thrown: \(error.localizedDescription)")
                    return
            }
            
            XCTAssertEqual((jsonError as NSError).code, 3840)
            
        }
        
    }
    
    func testHandleUnexpectedType() {
        
        do {
            let _: NotCodable = try gcf.parseData(from: data)
        } catch let error {
            
            XCTAssertTrue(error is GCFError.ParsingError, "wrong error was thrown: \(error.localizedDescription)")
            
        }
        
        do {
            let weirdType: NotCodable? = try gcf.parseData(from: data)
            
            XCTAssertNil(weirdType)
        } catch let error {
            
            XCTFail("error was thrown but should have been ignored: \(error.localizedDescription)")
            
        }
    }
    
    func testGetUnsafeTypeError() {
        
        do {
            let _: NotCodable = try JSONDecoder().decodeIfValid(NotCodable.self, with: data)
        } catch let error {
            
            guard
                case GCFError.ParsingError.codable(let decodableError?) = error,
                case DecodingError.dataCorrupted(let context) = decodableError
            else {
                XCTFail("wrong error was thrown: \(error.localizedDescription)")
                return
            }
            
            XCTAssertEqual(context.debugDescription, "Expected type NotCodable does not conform to protocol Decodable")
            
        }
    }
    
}
