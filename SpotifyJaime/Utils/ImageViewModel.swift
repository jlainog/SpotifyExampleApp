//
//  ImageViewModel.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import UIKit

class ImageViewModel {
    fileprivate let placeholder = UIImage(named: "small_ph")!
    fileprivate let error = UIImage(named: "small_ph_error")!
    fileprivate let imageURL : String?
    
    init(imageURL: String?) {
        self.imageURL = imageURL
    }
    
    func loadImageIn(imageView: UIImageView, roundImage: Bool = true) {
        if roundImage { self.roundImage(imageView: imageView) }
        
        guard let urlString = imageURL,
            let url = URL(string: urlString) else {
                imageView.image = placeholder
                return
        }
        
        imageView.af_setImage(withURL: url, placeholderImage: placeholder) { (response) in
            switch response.result {
            case .success(let image):
                imageView.image = image
            case .failure(_):
                imageView.image = self.error
            }
        }
    }
    
    private func roundImage(imageView: UIImageView) {
        imageView.layer.borderWidth = 1.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }
}
