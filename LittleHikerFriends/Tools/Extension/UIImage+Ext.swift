//
//  UIImage+Ext.swift
//  LittleHikerFriends
//
//  Created by Kyuhee hong on 8/3/25.
//

import UIKit

extension UIImage {
    static func resize(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
