//
//  ExoplanetStore.swift
//  benchmarks
//
//  Created by Tom Ebergen on 8/3/23.
//

import DuckDB
import Foundation
import TabularData

final class TPCHData {
    let database: Database
    let connection: Connection
  // Factory method to create and prepare a new ExoplanetStore
    static func create() async throws -> TPCHData {

        // Create our database and connection as described above
        let database = try Database(store: .inMemory)
        let connection = try database.connect()
        
        print("here dood")

        do {
            // create the tpch data
//            try connection.execute("install tpch;")
//            let result = try connection.execute("load tpch;")
            try connection.execute("import database '/Users/tomebergen/benchmarks/tpch';")
        } catch {
            print("some error here, uh-oh")
        }

        // Create our pre-populated ExoplanetStore instance
        return TPCHData(
            database: database,
            connection: connection
        )
    }

  // Let's make the initializer we defined previously
  // private. This prevents anyone accidentally instantiating
  // the store without having pre-loaded our Exoplanet CSV
  // into the database
    private init(database: Database, connection: Connection) {
      self.database = database
      self.connection = connection
    }
}


extension TPCHData {
    // Retrieves the number of exoplanets discovered by year
    func GetLineItem() async throws -> DataFrame {

        // Issue the query we described above
        let result = try connection.query("""
          Select * from lineitem;
          """)

        // Cast our DuckDB columns to their native Swift
        // equivalent types
        let l_orderkey = result[0].cast(to: Int.self)
        let l_partkey = result[1].cast(to: Int.self)
        let l_suppkey = result[2].cast(to: Int.self)
        let l_linenumber = result[3].cast(to: Int.self)
        let l_quantity = result[4].cast(to: Decimal.self)
        let l_extendedprice = result[5].cast(to: Decimal.self)
        let l_discount = result[6].cast(to: Decimal.self)
        let l_tax = result[7].cast(to: Decimal.self)
        let l_returnflag = result[8].cast(to: String.self)
        let l_linestatus = result[9].cast(to: String.self)
        let l_shipdate = result[10].cast(to: Date.self)
        let l_commitdate = result[11].cast(to: Date.self)
        let l_receiptdate = result[12].cast(to: Date.self)
        let l_shipinstruct = result[13].cast(to: String.self)
        let l_shipmode = result[14].cast(to: String.self)
        let l_shipcomment = result[15].cast(to: String.self)

        // Use our DuckDB columns to instantiate TabularData
        // columns and populate a TabularData DataFrame
        let rezzy = DataFrame(columns: [
            TabularData.Column(l_orderkey)
              .eraseToAnyColumn(),
            TabularData.Column(l_partkey)
              .eraseToAnyColumn(),
            TabularData.Column(l_suppkey)
              .eraseToAnyColumn(),
            TabularData.Column(l_linenumber)
              .eraseToAnyColumn(),
            TabularData.Column(l_quantity)
              .eraseToAnyColumn(),
            TabularData.Column(l_extendedprice)
              .eraseToAnyColumn(),
            TabularData.Column(l_discount)
              .eraseToAnyColumn(),
            TabularData.Column(l_tax)
              .eraseToAnyColumn(),
            TabularData.Column(l_returnflag)
              .eraseToAnyColumn(),
            TabularData.Column(l_linestatus)
              .eraseToAnyColumn(),
            TabularData.Column(l_shipdate)
              .eraseToAnyColumn(),
            TabularData.Column(l_commitdate)
              .eraseToAnyColumn(),
            TabularData.Column(l_receiptdate)
              .eraseToAnyColumn(),
          ])
        return rezzy
    }
}
