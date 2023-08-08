//
//  UIImage+Circle.swift
//  Vance
//
//  Created by Egor Molchanov on 23.06.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import UIKit

extension UIImage {
    static func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        let image = renderer.image { context in
            let rect = CGRect(x: 0.0, y: 0.0, width: diameter, height: diameter)
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.fillEllipse(in: rect)
        }
        return image
    }
}
