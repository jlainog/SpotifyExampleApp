//
//  ServiceError.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case failure(String)
    case noInternetConnection
}

extension ServiceError {
    public var localizedDescription: String {
        switch self {
        case ServiceError.failure(let value): return value
        case ServiceError.noInternetConnection: return "No Internet Connection"
        }
    }
}

extension ServiceError: Equatable {
    static func ==(lhs: ServiceError, rhs: ServiceError) -> Bool {
        switch (lhs, rhs) {
        case let (.failure(l), .failure(r)): return l == r
        case (.noInternetConnection, .noInternetConnection): return true
        default: return false
        }
    }
}
