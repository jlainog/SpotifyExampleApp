//
//  Result.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

enum Result<T> {
    case Success(T)
    case Failure(Error)
}

extension Result: Equatable where T: Equatable {
    static func ==(lhs: Result, rhs: Result) -> Bool {
        switch (lhs, rhs) {
        case let (.Success(l), .Success(r)): return l == r
        case let (.Failure(l), .Failure(r)): return l == r
        default: return false
        }
    }
}

private func ==(lhs: Error, rhs: Error) -> Bool {
    guard let lhsError = lhs as? ServiceError,
        let rhsError = rhs as? ServiceError else { return false }
    
    return lhsError == rhsError
}

extension Result {
    init(_ throwingExpr : (() throws -> T)) {
        do {
            let value = try throwingExpr()
            self = Result.Success(value)
        } catch {
            self = Result.Failure(error)
        }
    }
    
    func resolve() throws -> T {
        switch self {
        case Result.Success(let value): return value
        case Result.Failure(let error): throw error
        }
    }
}

extension Result {
    @discardableResult
    func error(_ f: (Error) -> Void) -> Result<T> {
        switch self {
        case Result.Success(let value): return .Success(value)
        case Result.Failure(let error): f(error); return self
        }
    }
    @discardableResult
    func value(_ f: (T) -> Void) -> Result<T> {
        switch self {
        case Result.Success(let value): f(value); return .Success(value)
        case Result.Failure(_): return self
        }
    }
}

extension Result {
    func map<U>(_ f: (T) -> U) -> Result<U> {
        switch self {
        case .Success(let t): return .Success(f(t))
        case .Failure(let err): return .Failure(err)
        }
    }
    func flatMap<U>(_ f: (T) -> Result<U>) -> Result<U> {
        switch self {
        case .Success(let t): return f(t)
        case .Failure(let err): return .Failure(err)
        }
    }
}
