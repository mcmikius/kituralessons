import Kitura
import HeliumLogger


HeliumLogger.use()

let router = Router()

router.get("customer") { request, response, next in
    let customer = Customer(firstName: "John", lastName: "Doe")
    
    response.send(json: customer.toDictionary())
    next()
}

router.get("/") { request, responce, next in
    responce.send("Hello World!")
    next()
}

Kitura.addHTTPServer(onPort: 8080, with: router)
Kitura.run()


