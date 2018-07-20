//
//  SpotifyAccessTokenHandler.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

final class SpotifyAccessTokenHandler : AccessTokenHandler {
    var token: AccessToken?
    let service: AccessTokenService
    static let shared = SpotifyAccessTokenHandler()
    
    init(service: AccessTokenService = SpotifyAccessTokenService()) {
        self.service = service
    }
}
