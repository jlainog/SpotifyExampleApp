//
//  AccessTokenService.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

protocol AccessToken : Codable {
    var expirationTime: Int { get }
    var requestedAt: Date { get }
    var type: String { get }
    var value: String { get }
}

extension AccessToken {
    func OAuthToken() -> String {
        return "\(type) \(value)"
    }
}

protocol AccessTokenService {
    func request(handler: @escaping (Result<AccessToken>) -> Void)
}
