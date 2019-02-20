import Kitura
import SwiftKuery
import SwiftKueryPostgreSQL
import HeliumLogger
import SwiftyJSON


HeliumLogger.use()

var router = Router()

let dishes = Dishes()

let connection = PostgreSQLConnection(host: "localhost", port: 5432, options: [.databaseName("nadiasgarden")])

func getAllDishes(callback: @escaping ([Dish]) -> ()) {
    let query = Select(dishes.key, dishes.title, dishes.description, dishes.course, dishes.imageURL, dishes.price, from: dishes)
    
    var dishesList = [Dish]()
    connection.connect { error in
        if let error = error {
            return
        }
        
        connection.execute(query: query, onCompletion: { result in
            if let rows = result.asRows {
                for row in rows {
                    var dictionary = [String: Any]()
                    
                    for (title, value) in row {
                        dictionary[title] = value
                    }
                    if let dish = Dish(dictionary: dictionary) {
                        dishesList.append(dish)
                    }
                }
            }
            callback(dishesList)
        })
    }
}
router.get("/dishes") { request, response, next in
    getAllDishes { dishes in
        response.send(json: dishes.map { $0.toDictionary() })
    }
    next()
}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()


