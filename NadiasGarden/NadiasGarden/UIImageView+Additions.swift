//
//  UIImageView+Additions.swift
//  NadiasGarden
//
//  Created by Michail Bondarenko on 2/20/19.
//  Copyright © 2019 Michail Bondarenko. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func setImageFor(url :URL, completion: @escaping (UIImage) -> ()) {
        
        DispatchQueue.global().async {
            
            let data = try? Data(contentsOf: url)
            
            if let data = data {
                
                let image = UIImage(data: data)
                
                DispatchQueue.main.async {
                    
                    completion(image!)
                    
                }
            }
        }
    }
    
}
