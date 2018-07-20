//
//  SpotifyAPI.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation
import Alamofire

struct SpotifyAPI {
    static let clientId = "2c410e69a4354ecebee6a36113b238af"
    static let clientSecret = "eab70899a88949c69754fceb773d8f11"
    static let basicAuth = (clientId + ":" + clientSecret).data(using: .utf8)!.base64EncodedString()
    
    static let basicParameters = ["grant_type": "client_credentials"]
    static let basicHeaders = ["Authorization": "Basic " + SpotifyAPI.basicAuth]
}

extension SpotifyAPI {
    static let baseURL = "https://api.spotify.com"
    static let seachPath = "/v1/search"
    static let albumsPath = "/v1/artists/%@/albums"
    static let tokenURL = "https://accounts.spotify.com/api/token"
}

extension SpotifyAPI {
    static func handleResponse(_ response: DataResponse<Any>) -> Result<[String: Any]> {
        return Result<[String: Any]> {
            guard let statusCode = response.response?.statusCode,
                let value = response.result.value as? [String: Any],
                response.result.isSuccess == true else {
                    if let error = response.result.error as NSError?, error.code == NSURLErrorNotConnectedToInternet {
                        throw ServiceError.noInternetConnection
                    }
                    throw ServiceError.failure("Something went wrong")
            }
            
            switch statusCode {
            case 200:
                return value
            default:
                var error = value["error"] as? [String: Any]
                let status = (error?["status"] as? Int) ?? 0
                let message = (error?["message"] as? String) ?? "Something went wrong"
                
                throw ServiceError.failure("\(status) - " + message)
            }
        }
    }
    
    static func parse<T: Codable>(_ json: [String: Any]) -> Result<T> {
        return Result<T> {
            let jsonData = try JSONSerialization.data(withJSONObject: json)
            let object = try JSONDecoder().decode(T.self, from: jsonData)
            
            return object
        }
    }
}
