//
//  EndlessScrollHandlerTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/16/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

class EndlessScrollHandlerTest: XCTestCase {
    var handler = EndlessScrollHandler(refreshLoaderHeight: 150)
    var scrollView : UIScrollView!
    
    override func setUp() {
        super.setUp()
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 0, height: 1000))
        scrollView.contentSize = CGSize(width: 0, height: 1600)
    }
    
    func testEndlessScrollHandler_InitialPosition() {
        handler.scrollViewIsReachingEnd = { XCTFail() }
        handler.scrollViewDidReachEnd = { XCTFail() }
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        handler.scrollViewDidScroll(scrollView)
    }
    
    func testEndlessScrollHandler_didReachRefreshHeight() {
        let expectation = self.expectation(description: "testEndlessScrollHandler_didReachRefreshHeight")
        let reachingEndOffset = round(scrollView.contentSize.height - scrollView.frame.height - handler.refreshLoaderHeight)
        
        handler.scrollViewIsReachingEnd = { expectation.fulfill() }
        handler.scrollViewDidReachEnd = { XCTFail() }
        scrollView.setContentOffset(CGPoint(x: 0, y: reachingEndOffset), animated: false)
        handler.scrollViewDidScroll(scrollView)
        handler.scrollViewIsReachingEnd = { XCTFail() }
        handler.scrollViewDidScroll(scrollView)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEndlessScrollHandler_didReachEnd() {
        let expectation = self.expectation(description: "testEndlessScrollHandler_didReachEnd")
        let reachEndOffset = round(scrollView.contentSize.height - scrollView.frame.height)
        
        handler.scrollViewIsReachingEnd = { expectation.fulfill() }
        handler.scrollViewDidReachEnd = { XCTFail() }
        scrollView.setContentOffset(CGPoint(x: 0, y: reachEndOffset), animated: false)
        handler.scrollViewDidScroll(scrollView)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEndlessScrollHandler_resetScroll() {
        let expectation = self.expectation(description: "testEndlessScrollHandler_resetScroll")
        let reachEndOffset = round(scrollView.contentSize.height - scrollView.frame.height)
        
        expectation.expectedFulfillmentCount = 3
        handler.scrollViewIsReachingEnd = { expectation.fulfill() }
        handler.scrollViewDidReachEnd = { XCTFail() }
        
        scrollView.setContentOffset(CGPoint(x: 0, y: reachEndOffset), animated: false)
        handler.scrollViewDidScroll(scrollView)
        handler.resetScroll()
        handler.scrollViewDidScroll(scrollView)
        handler.resetScroll()
        handler.scrollViewDidScroll(scrollView)
        waitForExpectations(timeout: 1, handler: nil)
    }
}
