//
//  RealmObjects.swift
//  benchmarks
//
//  Created by Tom Ebergen on 8/3/23.
//

import Foundation
import RealmSwift

class customer: Object {
    @objc dynamic var custKey = 0
    @objc dynamic var name = ""
    @objc dynamic var address = ""
    @objc dynamic var nationKey = 0
    @objc dynamic var phone = ""
    @objc dynamic var acctBalance = 0.0
    @objc dynamic var marketSegment = ""
    @objc dynamic var comment = ""

    override static func primaryKey() -> String? {
        return "custKey"
    }
}

class orders: Object {
    @objc dynamic var orderKey = 0
    @objc dynamic var custKey = 0
    @objc dynamic var orderStatus = ""
    @objc dynamic var totalPrice = 0.0
    @objc dynamic var orderDate = Date()
    @objc dynamic var orderPriority = ""
    @objc dynamic var clerk = ""
    @objc dynamic var shipPriority = 0
    @objc dynamic var comment = ""

    override static func primaryKey() -> String? {
        return "orderKey"
    }
}

class lineitem: Object {
    @objc dynamic var orderKey = 0
    @objc dynamic var partKey = 0
    @objc dynamic var suppKey = 0
    @objc dynamic var lineNumber = 0
    @objc dynamic var quantity = 0.0
    @objc dynamic var extendedPrice = 0.0
    @objc dynamic var discount = 0.0
    @objc dynamic var tax = 0.0
    @objc dynamic var returnFlag = ""
    @objc dynamic var lineStatus = ""
    @objc dynamic var shipDate = Date()
    @objc dynamic var commitDate = Date()
    @objc dynamic var receiptDate = Date()
    @objc dynamic var shipInstructions = ""
    @objc dynamic var shipMode = ""
    @objc dynamic var comment = ""

    override static func primaryKey() -> String? {
        return "lineNumber"
    }
}

class Nation: Object {
    @objc dynamic var nationKey = 0
    @objc dynamic var name = ""
    @objc dynamic var regionKey = 0
    @objc dynamic var comment = ""

    override static func primaryKey() -> String? {
        return "nationKey"
    }
}

class Part: Object {
    @objc dynamic var partKey = 0
    @objc dynamic var name = ""
    @objc dynamic var mfgr = ""
    @objc dynamic var brand = ""
    @objc dynamic var type = ""
    @objc dynamic var size = 0
    @objc dynamic var container = ""
    @objc dynamic var retailPrice = 0.0
    @objc dynamic var comment = ""

    override static func primaryKey() -> String? {
        return "partKey"
    }
}

class PartSupp: Object {
    @objc dynamic var partKey = 0
    @objc dynamic var suppKey = 0
    @objc dynamic var availQty = 0
    @objc dynamic var supplyCost = 0.0
    @objc dynamic var comment = ""

    // Composite primary key: partKey and suppKey
    override static func primaryKey() -> String? {
        return "partKey"
    }

    // Specify the composite properties to create a composite primary key
    func compositeKey() -> String {
        return "\(partKey)-\(suppKey)"
    }
}

class Region: Object {
    @objc dynamic var regionKey = 0
    @objc dynamic var name = ""
    @objc dynamic var comment = ""

    override static func primaryKey() -> String? {
        return "regionKey"
    }
}

class Supplier: Object {
    @objc dynamic var suppKey = 0
    @objc dynamic var name = ""
    @objc dynamic var address = ""
    @objc dynamic var nationKey = 0
    @objc dynamic var phone = ""
    @objc dynamic var acctBalance = 0.0
    @objc dynamic var comment = ""

    override static func primaryKey() -> String? {
        return "suppKey"
    }
}

func createSupplier() -> Supplier {
    let supplier = Supplier()
    supplier.suppKey = 1
    supplier.name = "ABC Electronics"
    supplier.address = "123 Main Street"
    supplier.nationKey = 1
    supplier.phone = "555-123-4567"
    supplier.acctBalance = 10000.0
    supplier.comment = "New supplier for electronics products"
    return supplier
}

//func getAlice() -> Supplier {
//    let realm = try! Realm()
//
//    let suppliersWithAlice = realm.objects(Supplier.self).filter("name = %@", "Alice")
//    return
//}

//class RealmDatabaseManager {
//    let realm = try! Realm()
//
//    func add(item: RealmItem) {
//        try! realm.write {
//            realm.add(item)
//        }
//    }
//
//    func getAllItems() -> Results<RealmItem> {
//        return realm.objects(RealmItem.self)
//    }
//
//    // Implement other CRUD operations as needed
//}
