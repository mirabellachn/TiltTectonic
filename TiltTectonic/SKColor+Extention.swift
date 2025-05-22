//
//  SKColor+Extention.swift
//  TiltTectonic
//
//  Created by Mirabella on 22/05/25.
//

import SpriteKit

extension SKColor {
    static func random() -> SKColor {
        return SKColor(
            red: CGFloat.random(in: 0.3...1),
            green: CGFloat.random(in: 0.3...1),
            blue: CGFloat.random(in: 0.3...1),
            alpha: 1.0
        )
    }
}
