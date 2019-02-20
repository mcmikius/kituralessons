//
//  Dish.swift
//  CHTTPParser
//
//  Created by Michail Bondarenko on 2/18/19.
//

import Foundation
import SwiftyJSON

class Dish {
    
    var id :Int32!
    var title :String!
    var price :Double!
    var description :String!
    var course :String!
    var imageURL :String!
    
    init?(json :JSON) {
        
        guard let title = json["title"].string,
            let price = json["price"].double,
            let description = json["description"].string,
            let course = json["course"].string,
            let imageURL = json["imageURL"].string
            else {
                return nil
        }
        
        self.title = title
        self.price = price
        self.description = description
        self.course = course
        self.imageURL = imageURL
        
    }
    
    init?(dictionary :[String:Any]) {
        
        guard let id = dictionary["id"] as? Int32,
            let title = dictionary["title"] as? String,
            let price = dictionary["price"] as? Double,
            let description = dictionary["description"] as? String,
            let course = dictionary["course"] as? String,
            let imageURL = dictionary["imageurl"] as? String
            else {
                return nil
        }
        
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.course = course
        self.imageURL = imageURL
    }
    
    func toDictionary() -> [String:Any] {
        return ["id":self.id,"title":self.title,
                "price":self.price,
                "description":self.description,
                "course":self.course,
                "imageURL":self.imageURL
        ]
    }
    
}

