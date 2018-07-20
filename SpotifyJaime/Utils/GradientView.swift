//
//  GradientView.swift
//  UIUtils
//
//  Created by Jaime Andres Laino Guerra on 4/25/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import UIKit

@IBDesignable
public class GradientView: UIView {
    
    @IBInspectable
    public var startColor: UIColor? {
        didSet { updateColors() }
    }
    
    @IBInspectable
    public var endColor: UIColor? {
        didSet { updateColors() }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func updateColors() {
        if let layer = self.layer as? CAGradientLayer,
            let startColor = self.startColor,
            let endColor = self.endColor {
            layer.colors = [startColor.cgColor, endColor.cgColor]
            setNeedsDisplay()
        }
    }
}
