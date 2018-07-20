//
//  MockAccessTokenService.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

struct MockAccessTokenService : AccessTokenService {
    enum TestOptions {
        case success(AccessToken)
        case failure(String)
        case noInternetConnection
    }
    let testOption : TestOptions
    
    init(testOption: TestOptions) {
        self.testOption = testOption
    }
    
    func request(handler: @escaping (Result<AccessToken>) -> Void) {
//        let result : Result<AccessToken>
//
//        switch testOption {
//        case .success(let accessToken):
//            result = Result.Success(accessToken)
//        case .failure(let error):
//            result = Result.Failure(ServiceError.failure(error))
//        case .noInternetConnection:
//            result = Result.Failure(ServiceError.noInternetConnection)
//        }
//
//        handler(result)
        
        handler(Result {
            switch testOption {
            case .success(let accessToken):
                return accessToken
            case .failure(let error):
                throw ServiceError.failure(error)
            case .noInternetConnection:
                throw ServiceError.noInternetConnection
            }
        })
    }
}
