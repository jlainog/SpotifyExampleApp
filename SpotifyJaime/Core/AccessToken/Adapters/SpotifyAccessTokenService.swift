//
//  SpotifyAccessTokenService.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation
import Alamofire

struct SpotifyAccessToken : AccessToken {
    let expirationTime: Int
    let requestedAt: Date
    let type: String
    let value: String
}

struct SpotifyAccessTokenService : AccessTokenService {
    func request(handler: @escaping (Result<AccessToken>) -> Void) {
        Alamofire.request(SpotifyAPI.tokenURL,
                          method: .post,
                          parameters: SpotifyAPI.basicParameters,
                          encoding: URLEncoding.default,
                          headers: SpotifyAPI.basicHeaders)
            .responseJSON { response in
                let result = SpotifyAPI.handleResponse(response)
                    .flatMap { self.buildToken($0) }
                
                handler(result)
        }
    }
    
    func buildToken(_ json: [String: Any]) -> Result<AccessToken> {
        return Result<AccessToken> {
            guard let tokenValue = json["access_token"] as? String,
                let tokenType = json["token_type"] as? String,
                let expirationTime = json["expires_in"] as? Int else {
                    throw ServiceError.failure("Something went wrong")
            }
            let token = SpotifyAccessToken(expirationTime: expirationTime,
                                           requestedAt: Date(),
                                           type: tokenType,
                                           value: tokenValue)
            
            return token
        }
    }
}
