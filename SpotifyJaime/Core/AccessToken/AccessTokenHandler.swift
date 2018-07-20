//
//  AccessTokenHandler.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

protocol AccessTokenHandler : AccessTokenService {
    var token : AccessToken? { get }
    var service : AccessTokenService { get }
}

extension AccessTokenHandler {
    func request(handler: @escaping (Result<AccessToken>) -> Void) {
        guard let token = self.token, existValidToken() else {
            service.request(handler: handler)
            return
        }
        
        handler(Result.Success(token))
    }
    
    func existValidToken() -> Bool {
        guard let token = self.token else { return false }
        let comps = (Calendar.current as NSCalendar).components(.second,
                                                                from: token.requestedAt as Date,
                                                                to: Date(),
                                                                options: NSCalendar.Options(rawValue: 0))
        
        return comps.second! < token.expirationTime
    }
}
