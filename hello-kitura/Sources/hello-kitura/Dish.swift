//
//  Dish.swift
//  CHTTPParser
//
//  Created by Michail Bondarenko on 2/18/19.
//

import Foundation

enum Course: String {
    case starters
    case entree
    case dessert
}

class Dish {
    var name: String
    var price: Double
    var course: Course
    
    init(name: String, price: Double, course: Course) {
        self.name = name
        self.price = price
        self.course = course
    }
    
    func toDictionary() -> [String: Any] {
        return ["name": self.name, "price": self.price, "course": self.course.rawValue]
    }
    
    static func all() -> [Dish] {
        return [Dish(name: "Parmesan Deviled Eggs", price: 8, course: .starters),
                Dish(name: "French Onion Soup", price: 7, course: .starters),
                Dish(name: "Classic Burger", price: 10, course: .entree),
                Dish(name: "Handcrafted Pizza", price: 10, course: .entree),
                Dish(name: "Creme Brulee", price: 9, course: .dessert),
                Dish(name: "Cheesecake", price: 9, course: .dessert),
                Dish(name: "Chocolate Chip Brownie", price: 6, course: .dessert),
                Dish(name: "Fiesta Family Platter", price: 16, course: .entree),
                Dish(name: "Barbecued Tofu Skewers", price: 10, course: .entree)
        ]
    }
    
    static func search(course: Course, price: Double = 0) -> [Dish]? {
        return all().filter { dish in
            return dish.course.rawValue.lowercased() == course.rawValue.lowercased() && dish.price >= price
        }
    }
}
