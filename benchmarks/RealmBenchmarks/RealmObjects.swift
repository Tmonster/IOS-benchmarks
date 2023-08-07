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
        
        let allLineItems = realm.objects(Lineitem.self)

        // Delete the objects currenlty in the realm db
        try! realm.write {
            realm.delete(allLineItems)
        }
        
        let l_orderkey = tpch_data[0].cast(to: Int.self)
        let l_partkey = tpch_data[1].cast(to: Int.self)
        let l_suppkey = tpch_data[2].cast(to: Int.self)
        let l_linenumber = tpch_data[3].cast(to: Int.self)
        let l_returnflag = tpch_data[8].cast(to: String.self)
        let l_linestatus = tpch_data[9].cast(to: String.self)
        let l_shipinstruct = tpch_data[13].cast(to: String.self)
        let l_shipmode = tpch_data[14].cast(to: String.self)
        let l_shipcomment = tpch_data[15].cast(to: String.self)

        var lineitems : [Lineitem] = []
        print("starting to write data to realm")
        for i in 0...(tpch_data.rowCount-1) {
            let l_item = Lineitem()
            l_item.orderKey = l_orderkey[i] ?? l_item.orderKey
            l_item.partKey = l_partkey[i] ?? l_item.partKey
            l_item.suppKey = l_suppkey[i] ?? l_item.suppKey
            l_item.lineNumber = l_linenumber[i] ?? l_item.lineNumber
            l_item.returnFlag = l_returnflag[i] ?? l_item.returnFlag
            l_item.lineStatus = l_linestatus[i] ?? l_item.lineStatus
            l_item.shipInstructions = l_shipinstruct[i] ?? l_item.shipInstructions
            l_item.shipMode = l_shipmode[i] ?? l_item.shipMode
            l_item.comment = l_shipcomment[i] ?? l_item.comment
            lineitems.append(l_item)
            if (i % 1000 == 0 && i > 0) {
                try! realm.write {
                    realm.add(lineitems)
                }
                print("written \(i) rows to realm")
                lineitems = []
            }
        }
        try! realm.write {
            realm.add(lineitems)
        }
        print("done writing data to realm")
    }
    
    static func GetLineItem() throws {
        let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        let realm = try Realm(configuration: configuration)
        
        let things = realm.objects(Lineitem.self)
        
        let avg_by_linenumber = things.
        
        print(order_keys)
    }
    
}


class Lineitem: Object {
    @objc dynamic var orderKey = 0
    @objc dynamic var partKey = 0
    @objc dynamic var suppKey = 0
    @objc dynamic var lineNumber = 0
    @objc dynamic var returnFlag = ""
    @objc dynamic var lineStatus = ""
    @objc dynamic var shipInstructions = ""
    @objc dynamic var shipMode = ""
    @objc dynamic var comment = ""
}
