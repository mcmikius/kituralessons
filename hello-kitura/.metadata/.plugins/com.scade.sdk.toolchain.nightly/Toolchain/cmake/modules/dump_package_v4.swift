
import Foundation

do {
    let inputData = FileHandle.standardInput.readDataToEndOfFile()
    let json = try JSONSerialization.jsonObject(with: inputData, options: []) as! [String: Any]

    print(json["name"] as! String)

    let deps = json["dependencies"] as! [Any]
    for dep in deps {
        let depDict = dep as! [String: Any]
        let url = depDict["url"] as! String
        let nm = (url as NSString).lastPathComponent
        print((nm as NSString).deletingPathExtension)
    }

    print("TARGETS")

    let targs = json["targets"] as! [Any]
    for targAny in targs {
        let targ = targAny as! [String: Any]
        if let isTest = targ["isTest"] as? Bool {
            if isTest {
                continue
            }
        }

        var targString = targ["name"] as! String
        var targPath = ""
        if let p = targ["path"] as? String {
            targPath = p
        }

        if targPath.isEmpty {
            targString += " <empty>"
        } else {
            targString += " " + targPath
        }


        let deps = targ["dependencies"] as! [Any]
        for dep in deps {
            let depDict = dep as! [String: Any]
            targString += " " + (depDict["name"] as! String)
        }

        print(targString)
    }

    print("PRODUCTS")

    let products = json["products"] as! [Any]
    for prodAny in products {
        let prod = prodAny as! [String: Any]

        var prodString = prod["name"] as! String
        prodString += " "

        let prodType = prod["product_type"] as! String
        if prodType == "executable" {
            prodString += "EXECUTABLE"
        } else if prodType == "library" {
            if let libType = prod["type"] as? String {
                if libType == "dynamic" {
                    prodString += "DYNAMIC_LIBRARY"
                } else {
                    prodString += "STATIC_LIBRARY"
                }
            } else {
                prodString += "STATIC_LIBRARY"
            }
        }

        let targets = prod["targets"] as! [String]
        for targ in targets {
            prodString += " " + targ
        }

        print(prodString)
    }
}
catch {
    print("\(error)")
    exit(1)
}

