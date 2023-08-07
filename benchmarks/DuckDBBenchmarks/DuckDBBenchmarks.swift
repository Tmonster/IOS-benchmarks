//
//  DuckDBBenchmarks.swift
//  benchmarks
//
//  Created by Tom Ebergen on 07/08/2023.
//
import Foundation
import DuckDB


final class DuckDBBenchmarks {
    let database: Database
    let connection: Connection
    
    private init(database: Database, connection: Connection) {
      self.database = database
      self.connection = connection
    }
    
    enum DuckdbError: Error {
        case ConversionError(String)
    }
    
    static func create() async throws -> DuckDBBenchmarks {

        // Create our database and connection as described above
        // ("/Users/tomebergen/IOS-benchmarks/row-insertion-check.duckdb")))
        do {
            let database = try Database(store: .file(at : URL(filePath: String("/Users/tomebergen/IOS-benchmarks/row-insertion-check.duckdb"))))
            let connection = try database.connect()
            
            // Create our pre-populated ExoplanetStore instance
            return DuckDBBenchmarks(
                database: database,
                connection: connection
            )
        } catch {
            print("an error occured \(error). ")
            throw error
        }
    }
    
    func Load(tpch_data : ResultSet) throws {
                
        print("starting duckdb data conversion")
        try connection.execute("DROP TABLE if exists new_lineitem")
        try connection.execute("CREATE TABLE IF NOT EXISTS new_lineitem(" +
                               "l_orderkey INTEGER," +
                               "l_partkey INTEGER, " +
                               "l_suppkey INTEGER," +
                               "l_linenumber INTEGER," +
                               "l_returnflag String," +
                               "l_linestatus String," +
                               "l_shipinstruct String," +
                               "l_shipmode String," +
                               "l_shipcomment String);")
        
        let appender = try Appender(connection: connection, table: "new_lineitem")
        
        // casting to Int is fine.
        let l_orderkey = tpch_data[0].cast(to: Int.self)
        // casting to IntHuge is fine
        let l_partkey = tpch_data[1].cast(to: Int.self)
        let l_suppkey = tpch_data[2].cast(to: Int.self)
        let l_linenumber = tpch_data[3].cast(to: Int.self)
        let l_returnflag = tpch_data[8].cast(to: String.self)
        let l_linestatus = tpch_data[9].cast(to: String.self)
        let l_shipinstruct = tpch_data[13].cast(to: String.self)
        let l_shipmode = tpch_data[14].cast(to: String.self)
        let l_shipcomment = tpch_data[15].cast(to: String.self)
        
        for i in 0...(tpch_data.rowCount-1) {
            guard let one_orderKey = l_orderkey[i] else {
                throw DuckdbError.ConversionError("orderkey is nil")
            }
            let one_orderKey_cast = Int64(one_orderKey)

            guard let one_partKey = l_partkey[i] else {
                throw DuckdbError.ConversionError("one_partKey is nil")
            }
            let one_partKey_cast = Int64(one_partKey)

            guard let one_suppKey = l_suppkey[i] else {
                throw DuckdbError.ConversionError("one_suppKey is nil")
            }
            let one_suppKey_cast = Int64(one_suppKey)

            guard let one_lineNumber = l_linenumber[i] else {
                throw DuckdbError.ConversionError("one_lineNumber is nil")
            }
            let one_lineNumber_cast = Int64(one_lineNumber)

            guard let one_returnFlag = l_returnflag[i] else {
                throw DuckdbError.ConversionError("one_returnFlag is nil")
            }
            let one_returnFlag_cast = String(one_returnFlag)

            guard let one_lineStatus = l_linestatus[i] else {
                throw DuckdbError.ConversionError("one_lineStatus is nil")
            }
            let one_lineStatus_cast = String(one_lineStatus)

            guard let one_shipInstructions = l_shipinstruct[i] else {
                throw DuckdbError.ConversionError("one_shipInstructions is nil")
            }
            let one_shipInstructions_cast = String(one_shipInstructions)

            guard let one_shipMode = l_shipmode[i] else {
                throw DuckdbError.ConversionError("one_shipMode is nil")
            }
            let one_shipMode_cast = String(one_shipMode)

            guard let one_comment = l_shipcomment[i] else {
                throw DuckdbError.ConversionError("one_comment is nil")
            }
            let one_comment_cast = String(one_comment)

            do {
                try appender.append(one_orderKey_cast)
                try appender.append(one_partKey_cast)
                try appender.append(one_suppKey_cast)
                try appender.append(one_lineNumber_cast)
                try appender.append(one_returnFlag_cast)
                try appender.append(one_lineStatus_cast)
                try appender.append(one_shipInstructions_cast)
                try appender.append(one_shipMode_cast)
                try appender.append(one_comment_cast)
                try appender.endRow()
            } catch {
                print("Error thrown during appending: \(error)")
            }

            if (i % 2048 == 0 && i > 0) {
                try appender.flush()
                print("flushing 2048 rows to duckdb")
            }
        }
        
        try appender.flush()
    }
    
}

extension DuckDBBenchmarks {
    // Retrieves the number of exoplanets discovered by year
    func GetLineItem() throws -> ResultSet {
        // Issue the query we described above
        let result = try connection.query("""
          select avg(l_partkey), l_linenumber from new_lineitem group by l_linenumber;
          """)
        return result;
    }
}


//class Lineitem: Object {
//    @objc dynamic var orderKey = 0
//    @objc dynamic var partKey = 0
//    @objc dynamic var suppKey = 0
//    @objc dynamic var lineNumber = 0
//    @objc dynamic var quantity : Double = 0.0
//    @objc dynamic var extendedPrice : Double = 0.0
//    @objc dynamic var discount : Double = 0.0
//    @objc dynamic var tax : Double = 0.0
//    @objc dynamic var returnFlag = ""
//    @objc dynamic var lineStatus = ""
//    @objc dynamic var shipDate = Date()
//    @objc dynamic var commitDate = Date()
//    @objc dynamic var receiptDate = Date()
//    @objc dynamic var shipInstructions = ""
//    @objc dynamic var shipMode = ""
//    @objc dynamic var comment = ""
//}
