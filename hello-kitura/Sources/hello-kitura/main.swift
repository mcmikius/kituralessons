import Kitura
import SwiftKuery
import SwiftKueryPostgreSQL
import HeliumLogger
import SwiftyJSON


HeliumLogger.use()

var router = Router()
router.all("/", middleware:BodyParser())

let dishes = Dishes()

let connection = PostgreSQLConnection(host: "localhost", port: 5432, options: [.databaseName("nadiasgarden")])
router.delete("/dish") { request, response, next in
    guard let parsedBody = request.body else {
        next()
        return
    }
    switch(parsedBody) {
    case .json(let jsonBody):
        let dishId = jsonBody["id"].int32
        let deleteQuery = Delete(from: dishes).where(dishes.key == Int(dishId!))
        connection.connect { error in
            if let error = error {
                return
            }
            connection.execute(query: deleteQuery) { result in
                response.send(json:["success": true])
            }
        }
    default:
        response.status(.badRequest).send("Bad Request")
    }
}
router.post("/dish") { request, response, next in
    guard let parsedBody = request.body else {
        next()
        return
    }
    switch(parsedBody) {
    case .json(let jsonBody):
        guard let dish = Dish(json: jsonBody) else {
            return
        }
        let insertQuery = Insert(into: dishes, columns: [dishes.title, dishes.price, dishes.description, dishes.course, dishes.imageURL], values:[dish.title, dish.price, dish.description, dish.course, dish.imageURL])
        connection.connect { error in
            connection.execute(query: insertQuery) { result in
                response.send(json: ["success": true, "message": "Dish has been inserted"])
            }
        }
    default:
        response.status(.badRequest).send("Bad Request")
    }
    next()
}

func getAllDishes(callback: @escaping ([Dish]) -> ()) {
    let query = Select(dishes.key, dishes.title, dishes.description, dishes.course, dishes.imageURL, dishes.price, from: dishes)
    
    var dishesList = [Dish]()
    connection.connect { error in
        if let error = error {
            return
        }
        
        connection.execute(query: query) { result in
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
        }
    }
}

func getDishesByCourse(course: String, callback: @escaping ([Dish]) -> ()) {
    let query = Select(dishes.key, dishes.title, dishes.description, dishes.course, dishes.imageURL, dishes.price, from: dishes).where(dishes.course == course)
    
    var dishesList = [Dish]()
    connection.connect { error in
        if let error = error {
            return
        }
        
        connection.execute(query: query) { result in
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
        }
    }
}

router.get("/dishes-by-course") { request, response, next in
    let course = request.queryParameters["course"] ?? ""
    if course.isEmpty {
        getAllDishes() {dishes in
            response.send(json: dishes.map { $0.toDictionary() })
        }
        next()
        return
    }
    getDishesByCourse(course: course) { dishes in
        response.send(json: dishes.map {$0.toDictionary()})
    }
    next()
    return
}
router.get("/dishes") { request, response, next in
    getAllDishes { dishes in
        response.send(json: dishes.map { $0.toDictionary() })
    }
    next()
}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()


