//
//  Dishes.swift
//  CHTTPParser
//
//  Created by Michail Bondarenko on 2/20/19.
//

import Foundation
import SwiftKuery
import SwiftKueryPostgreSQL

class Dishes : Table {
    
    let tableName = "dishes"
    let key = Column("id")
    let title = Column("title")
    let price = Column("price")
    let description = Column("description")
    let course = Column("course")
    let imageURL = Column("imageurl")
}
