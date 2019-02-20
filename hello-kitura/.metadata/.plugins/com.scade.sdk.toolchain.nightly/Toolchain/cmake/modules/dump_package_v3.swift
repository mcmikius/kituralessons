
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

        var targString = targ["name"] as! String

        let deps = targ["dependencies"] as! [String]
        for dep in deps {
            targString += " " + dep
        }

        print(targString)
    }
}
catch {
    print("\(error)")
    exit(1)
}

