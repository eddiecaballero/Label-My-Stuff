//
//  UIColor+.swift
//  Label My Stuff
//
//  Created by Eddie Caballero on 5/7/22.
//  Copyright © 2022 Eddie Caballero. All rights reserved.
//

import UIKit

@objc extension UIColor {
    class var systemBackgroundColorLegacy: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        } else {
            return .white
        }
    }
    
    class var labelColorLegacy: UIColor {
        if #available(iOS 13, *) {
            return .label
        } else {
            return .black
        }
    }
    
    class var whiteColorLegacy: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        } else {
            return .white
        }
    }
    
    class var blackColorLegacy: UIColor {
        if #available(iOS 13, *) {
            return .label
        } else {
            return .black
        }
    }
    
    class var systemRedColorLegacy: UIColor {
        if #available(iOS 13, *) {
            return .systemRed
        } else {
            return .red
        }
    }
    
    class var systemBlueColorLegacy: UIColor {
        if #available(iOS 13, *) {
            return .systemBlue
        } else {
            return .blue
        }
    }
}
