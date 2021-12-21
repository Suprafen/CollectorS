//
//  Extensions.swift
//  collector
//
//  Created by Ivan Pryhara on 13.12.21.
//

import Foundation
import UIKit

extension Data {
    static func encode(image: UIImage) -> Data {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {return Data()}
        
        return imageData
    }
}
