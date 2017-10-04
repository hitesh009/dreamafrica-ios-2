//
//  GradientView.swift
//  Butter
//
//  Created by DjinnGA on 27/09/2015.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable class GradientView: UIView {
    
    @IBInspectable var topColor: UIColor? {
        didSet {
            configureView()
        }
    }
    @IBInspectable var bottomColor: UIColor? {
        didSet {
            configureView()
        }
    }
    
    override class var layerClass : AnyClass {
        return CAGradientLayer.self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        configureView()
    }
    
    func configureView() {
        let layer = self.layer as! CAGradientLayer
        let locations = [ 0.0, 1.0 ]
        layer.locations = locations as [NSNumber]
        let color1 = topColor ?? self.tintColor as UIColor
        let color2 = bottomColor ?? UIColor.black as UIColor
        let colors: Array <AnyObject> = [ color1.cgColor, color2.cgColor ]
        layer.colors = colors
    }
    
}
