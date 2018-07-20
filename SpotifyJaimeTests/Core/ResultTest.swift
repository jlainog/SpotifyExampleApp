//
//  ResultTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

class ResultTest: XCTestCase {
    
    func testResult_throwingExprSuccess() {
        let testValue = 100
        let sut = Result { return testValue }
        
        do {
            let value = try sut.resolve()
            
            XCTAssertEqual(value, testValue)
        } catch {
            guard case .noInternetConnection? = (error as? ServiceError) else {
                XCTFail()
                return
            }
        }
    }
    
    func testResult_throwingExprFailure() {
        let sut = Result { throw ServiceError.noInternetConnection }
        
        do {
            _ = try sut.resolve()
            XCTFail()
        } catch {
            guard case .noInternetConnection? = (error as? ServiceError) else {
                XCTFail()
                return
            }
        }
    }
    
    func testResult_Value() {
        let testValue = 100
        let result = Result.Success(testValue)
        let returnedResult = result.value { (value) in
            XCTAssertEqual(value, testValue)
        }
        
        XCTAssertEqual(returnedResult, result)
    }
    
    func testResult_Error() {
        let testError = ServiceError.noInternetConnection
        let result = Result<Int>.Failure(testError)
        let returnedResult = result.error { (err) in
            XCTAssertEqual(testError, ServiceError.noInternetConnection)
        }
        
        XCTAssertEqual(returnedResult, result)
    }
    
    func testResult_Map() {
        let testValue = 100
        let result = Result.Success(testValue)
        let returnedResult = result.map { value in
            return value * testValue
        }
        
        returnedResult.value { (value) in
            XCTAssertEqual(value, testValue * testValue)
        }
    }
    
    func testResult_FlatMap() {
        let testValue = 100
        let result = Result.Success(testValue)
        let returnedResult = result.flatMap { value in
            return .Success(value * testValue)
        }
        let failedResult = result.flatMap { value in
            return Result<Int>.Failure(ServiceError.noInternetConnection)
        }
        
        returnedResult.value { (value) in
            XCTAssertEqual(value, testValue * testValue)
        }
        failedResult.error { err in
            guard case .noInternetConnection? = (err as? ServiceError) else {
                XCTFail()
                return
            }
        }
    }
}
