//
//  MockSearchService.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

struct MockSearchService : SearchService {
    enum TestOptions {
        case success(SearchList)
        case failure(String)
        case noInternetConnection
    }
    let testOption : TestOptions
    let delay : Int
    
    init(testOption: TestOptions, delay: Int = 0) {
        self.testOption = testOption
        self.delay = delay
    }
    
    func search(_ query: String, handler: @escaping (Result<SearchList>) -> Void) {
        let block = {
            handler(Result {
                switch self.testOption {
                case .success(var list):
                    list.query = query
                    return list
                case .failure(let error):
                    throw ServiceError.failure(error)
                case .noInternetConnection:
                    throw ServiceError.noInternetConnection
                }
            })
        }
        
        if delay == 0 {
            block()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay), execute: block)
    }
}
