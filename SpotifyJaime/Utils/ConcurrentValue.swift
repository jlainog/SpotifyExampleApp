//
//  ConcurrentValue.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

class ConcurrentValue<T> {
    private var _value : T?
    private let concurrentQueue : DispatchQueue
    
    init(queueLabel: String) {
        concurrentQueue = DispatchQueue(label: queueLabel,
                                        attributes: .concurrent)
    }
    
    var value : T? {
        get {
            return concurrentQueue.sync { _value }
        }
        set {
            concurrentQueue.async(flags: .barrier) {
                self._value = newValue
            }
        }
    }
}
