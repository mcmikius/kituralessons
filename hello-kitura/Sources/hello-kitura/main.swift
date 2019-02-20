import Kitura
import HeliumLogger
import SwiftyJSON


HeliumLogger.use()

let router = Router()


router.post(middleware: BodyParser())

router.post("dishes-by-course") { request, response, next in
    guard let parsedBody = request.body else {
        try response.status(.badRequest).end()
        return
    }
    switch(parsedBody) {
    case .json(let jsonBody):
        let course = jsonBody["course"].string ?? ""
        if let selectedCourse = Course(rawValue: course.lowercased()) {
            if let dishes = Dish.search(course: selectedCourse) {
                response.send(json: dishes.map { $0.toDictionary() })
            }
        }
    default:
        break
    }
    next()
}

router.get("search") { request, response, next in
    guard let course = request.queryParameters["course"], let price = request.queryParameters["price"] else {
        try response.status(.badRequest).end()
        return
    }
    if let dishes = Dish.search(course: Course(rawValue: course)!, price: Double(price)!) {
        response.send(json: dishes.map { $0.toDictionary() })
    }
    next()
}

router.post("register") { request, response, next in
    guard let body = request.body, let values = body.asURLEncoded, let firstName = values["firstName"], let lastName = values["lastName"] else {
        try response.status(.badRequest).end()
        return
    }
    response.send("First Name = \(firstName) and Last Name = \(lastName)")
    next()
}
router.get("/movies/:genre/year/:year") { request, response,next in
    guard let genre = request.parameters["genre"], let year = request.parameters["year"] else {
        try response.status(.badRequest).end()
        return
    }
    
    response.send("\(genre) and the year is \(year)")
    next()
}

router.get("/movies/:genre") { request, response, next in
    guard let genre = request.parameters["genre"] else {
        try response.status(.badRequest).end()
        return
    }
    
    response.send("You selected \(genre)")
    next()
}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()


