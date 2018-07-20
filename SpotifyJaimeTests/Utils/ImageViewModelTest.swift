//
//  ImageViewModelTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

class ImageViewModelTest: XCTestCase {
    
    func testImageViewModel_loadFailed() {
        let imageViewModel : ImageViewModel
        let imageView = UIImageView()
        let waitForResponse = expectation(description: "testImageViewModel_loadFailed")
        
        imageViewModel = ImageViewModel(imageURL: "www.mock.com")
        imageViewModel.loadImageIn(imageView: imageView)
        XCTAssertEqual(imageView.image, UIImage(named: "small_ph")!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            waitForResponse.fulfill()
            XCTAssertEqual(imageView.image, UIImage(named: "small_ph_error")!)
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
    func testImageViewModel_placeHolder() {
        let imageViewModel : ImageViewModel
        let imageView = UIImageView()
        
        imageViewModel = ImageViewModel(imageURL: nil)
        imageViewModel.loadImageIn(imageView: imageView)
        XCTAssertEqual(imageView.image, UIImage(named: "small_ph")!)
    }
    
    func testImageViewModel_roundCorners() {
        let imageViewModel : ImageViewModel
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        imageViewModel = ImageViewModel(imageURL: nil)
        imageViewModel.loadImageIn(imageView: imageView, roundImage: false)
        XCTAssertEqual(imageView.layer.cornerRadius, 0)
        imageViewModel.loadImageIn(imageView: imageView)
        XCTAssertEqual(imageView.layer.cornerRadius, 50)
    }
}
