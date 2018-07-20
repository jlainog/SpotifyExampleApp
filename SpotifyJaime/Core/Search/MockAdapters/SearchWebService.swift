//
//  SearchWebService.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation
import Alamofire

struct SearchWebService : SearchService {
    private let pageLimit = 4
    let concurrentRequest = ConcurrentValue<DataRequest>(queueLabel: "SearchWebService")
    
    func search(_ query: String, handler: @escaping (Result<SearchList>) -> Void) {
        SpotifyAccessTokenHandler.shared.request { result in
            result.error { handler(.Failure($0)) }
                .value { (token) in
                    let urlRequest = SpotifyAPI.baseURL + SpotifyAPI.seachPath
                    
                    DispatchQueue.global().async {
                        let dataRequest = Alamofire.request(urlRequest,
                                                            parameters: ["q": query,
                                                                         "offset": 0,
                                                                         "type": "artist,album",
                                                                         "limit": self.pageLimit],
                                                            headers: ["Authorization":token.OAuthToken()])
                        
                        self.concurrentRequest.value?.cancel()
                        self.concurrentRequest.value = dataRequest
                        dataRequest.responseJSON { (response) in
                            if (self.concurrentRequest.value!.request != dataRequest.request) { return }
                            
                            let result = SpotifyAPI.handleResponse(response)
                                .flatMap { SpotifyAPI.parse($0) as Result<SearchList> }
                            
                            DispatchQueue.main.async {
                                handler(result)
                            }
                        }
                    }
            }
        }
    }
}
