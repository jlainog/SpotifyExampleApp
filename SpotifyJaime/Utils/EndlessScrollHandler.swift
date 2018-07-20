//
//  EndlessScrollHandler.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import UIKit

public struct EndlessScrollHandler {
    public let refreshLoaderHeight : CGFloat
    public var scrollViewIsReachingEnd : (() -> Void)? = nil
    public var scrollViewDidReachEnd : (() -> Void)? = nil
    fileprivate var lastContentSize = CGSize(width: 0, height: 0)
    
    public init(refreshLoaderHeight: CGFloat) {
        self.refreshLoaderHeight = refreshLoaderHeight
    }
    
    public mutating func resetScroll() {
        lastContentSize = CGSize(width: 0, height: 0)
    }
    
    public mutating func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let refreshingHeigth = round(scrollView.contentSize.height - scrollView.frame.size.height - refreshLoaderHeight);
        
        if (scrollView.contentOffset.y >= refreshingHeigth) {
            if (!scrollView.contentSize.equalTo(lastContentSize)) {
                lastContentSize = scrollView.contentSize;
                scrollViewIsReachingEnd?()
            } else if (scrollView.contentOffset.y == (scrollView.contentSize.height - scrollView.bounds.size.height)) {
                scrollViewDidReachEnd?()
            }
        }
    }
}
