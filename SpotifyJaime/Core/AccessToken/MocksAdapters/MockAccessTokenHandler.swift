//
//  MockAccessTokenHandler.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

final class MockAccessTokenHandler : AccessTokenHandler {
    var token: AccessToken?
    var service: AccessTokenService
    
    init(service: AccessTokenService) {
        self.service = service
    }
}
