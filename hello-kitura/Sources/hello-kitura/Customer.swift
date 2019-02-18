//
//  Customer.swift
//  hello-kitura
//
//  Created by Michail Bondarenko on 2/18/19.
//

import Foundation

class Customer {
    var firstName: String
    var lastName: String
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    func toDictionary() -> [String: Any] {
        return ["firstName": self.firstName, "lastName": self.lastName]
    }
}
