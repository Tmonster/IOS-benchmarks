//
//  RealmObjects.swift
//  benchmarks
//
//  Created by Tom Ebergen on 8/3/23.
//

import Foundation
import RealmSwift
import DuckDB

final class RealmObjects {
    static func Load(tpch_data : ResultSet) throws {
        
        let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        let realm = try Realm(configuration: configuration)
        
        
        
        let l_orderkey = tpch_data[0].cast(to: Int.self)
        let l_partkey = tpch_data[1].cast(to: Int.self)
        let l_suppkey = tpch_data[2].cast(to: Int.self)
        let l_linenumber = tpch_data[3].cast(to: Int.self)
//        let l_quantity = tpch_data[4].cast(to: Decimal.self)
//        let l_extendedprice = tpch_data[5].cast(to: Decimal.self)
//        let l_discount = tpch_data[6].cast(to: Decimal.self)
//        let l_tax = tpch_data[7].cast(to: Decimal.self)
        let l_returnflag = tpch_data[8].cast(to: String.self)
        let l_linestatus = tpch_data[9].cast(to: String.self)
//        let l_shipdate = tpch_data[10].cast(to: Date.self)
//        let l_commitdate = tpch_data[11].cast(to: Date.self)
//        let l_receiptdate = tpch_data[12].cast(to: Date.self)
        let l_shipinstruct = tpch_data[13].cast(to: String.self)
        let l_shipmode = tpch_data[14].cast(to: String.self)
        let l_shipcomment = tpch_data[15].cast(to: String.self)

        for i in 0...tpch_data.rowCount {
            var l_item = Lineitem()
            l_item.orderKey = l_orderkey[i] ?? l_item.orderKey
            l_item.partKey = l_partkey[1] ?? l_item.partKey
            l_item.suppKey = l_suppkey[2] ?? l_item.suppKey
            l_item.lineNumber = l_linenumber[3] ?? l_item.lineNumber
//            l_item.quantity = l_quantity[4] ?? l_item.quantity
//            l_item.extendedPrice = l_extendedprice[5] ?? l_item.extendedPrice
//            l_item.discount = l_discount[6] ?? l_item.discount
//            l_item.tax = l_tax[7] ?? l_item.tax
            l_item.returnFlag = l_returnflag[8] ?? l_item.returnFlag
            l_item.lineStatus = l_linestatus[9] ?? l_item.lineStatus
            l_item.shipInstructions = l_shipinstruct[13] ?? l_item.shipInstructions
            l_item.shipMode = l_shipmode[14] ?? l_item.shipMode
            l_item.comment = l_shipcomment[15] ?? l_item.comment
            
            try! realm.write {
                realm.add(l_item)
            }
        }
    }
    
    static func Query() throws {
        let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        let realm = try Realm(configuration: configuration)
        
        let things = realm.objects(Lineitem.self)
        
        let order_keys = things.where {
            $0.orderKey == 5
        }
        
        print(order_keys)
    }
    
}

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

class Lineitem: Object {
    @objc dynamic var orderKey = 0
    @objc dynamic var partKey = 0
    @objc dynamic var suppKey = 0
    @objc dynamic var lineNumber = 0
    @objc dynamic var quantity : Double = 0.0
    @objc dynamic var extendedPrice : Double = 0.0
    @objc dynamic var discount : Double = 0.0
    @objc dynamic var tax : Double = 0.0
    @objc dynamic var returnFlag = ""
    @objc dynamic var lineStatus = ""
    @objc dynamic var shipDate = Date()
    @objc dynamic var commitDate = Date()
    @objc dynamic var receiptDate = Date()
    @objc dynamic var shipInstructions = ""
    @objc dynamic var shipMode = ""
    @objc dynamic var comment = ""
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
