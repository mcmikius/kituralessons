//
//  Dish.swift
//  NadiasGarden
//
//  Created by Michail Bondarenko on 2/20/19.
//  Copyright © 2019 Michail Bondarenko. All rights reserved.
//

import Foundation

class Dish {
    
    var id :Int?
    var title :String!
    var description :String!
    var price :Double!
    var course :String!
    var imageURL :String!
    
    init(title :String, description :String, price :Double, course :String, imageURL :String) {
        self.title = title
        self.description = description
        self.price = price
        self.course = course
        self.imageURL = imageURL
    }
    
    init?(dictionary :[String:Any]) {
        
        guard let id = dictionary["id"] as? Int,
            let title = dictionary["title"] as? String,
            let description = dictionary["description"] as? String,
            let price = dictionary["price"] as? Double,
            let course = dictionary["course"] as? String,
            let imageURL = dictionary["imageURL"] as? String else {
                return nil
        }
        
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.course = course
        self.imageURL = imageURL
    }
    
    func toDictionary() -> [String:Any] {
        return ["id":self.id,"title":self.title,
                "description":self.description,
                "price":self.price,
                "course":self.course,
                "imageURL":self.imageURL
        ]
    }
    
}

