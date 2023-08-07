//
//  ContentView.swift
//  benchmarks
//
//  Created by Tom Ebergen on 8/3/23.
//

import SwiftUI
import CoreData
import DuckDB
import RealmSwift
import TabularData


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<Item>
    
    private enum ViewState {
        case ready_to_load
        case loading
        case data_is_loaded
        case data_is_queried
        case converting_data
        case loading_error
        case querying_data
        case data_is_converted
    }
    
    @State private var state = ViewState.ready_to_load
    @State private var tpch_data : TPCHData?
    @State private var duckdb_instance : DuckDBBenchmarks?
    @State private var realm_load_time : String = "no realm load time available"
    @State private var duckdb_load_time : String = "no duckdb load time available"
    @State private var realm_query_time : String = "no realm query time available"
    @State private var duckdb_query_time : String = "no duckdb query time available"

    var body: some View {
        Group {
            switch state {
            case .ready_to_load:
                Text("data is ready to load")
            case .loading:
                Text("loading data")
            case .data_is_loaded:
                Text("data is loaded")
            case .data_is_queried:
                Text("data has been queried")
            case .querying_data:
                Text("querying data")
            case .loading_error:
                Text("loading error")
            case .converting_data:
                Text("converting data to Realm")
            case .data_is_converted:
                Text("data is converted")
            }
        }
        Text(self.realm_load_time).padding()
        Text(self.duckdb_load_time).padding()
        VStack {
            Button("Load Data") {
                loadData()
            }
            .padding()
            
            Button("Load Data into Realm DB") {
                LoadDataInRealm()
            }
            .padding()
            
            Button("Load Data into DuckDB") {
                LoadDataInDuckDB()
            }
            .padding()
            
            Button("Query Realm Data") {
                QueryDataRealm()
            }
            .padding()
            
            Text(self.realm_query_time).padding()
            
            Button("Query Duckdb Data") {
                QueryDataDuckDB()
            }.padding()
            Text(self.duckdb_query_time).padding()
        }
    }
    
    private func loadData() {
        guard case .ready_to_load = state else { return }
        self.state = .loading
        Task {
            do {
                tpch_data = try await TPCHData.create()
                self.state = .data_is_loaded
            }
            catch {
                self.state = .loading_error
            }
        }
    }
    
    private func LoadDataInRealm() {
        self.state = .converting_data
        Task {
            if let tpch_data {
                let results = try await tpch_data.GetLineItem()
                let startTime = CFAbsoluteTimeGetCurrent()
                try RealmObjects.Load(tpch_data : results)
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                self.realm_load_time = "Realm load tpch sf=0.001 = \(timeElapsed)"
                self.state = .data_is_converted
            }
        }
    }
    
    private func LoadDataInDuckDB() {
        self.state = .converting_data
        Task {
            if let tpch_data {
                let results = try await tpch_data.GetLineItem()
                self.duckdb_instance = try await DuckDBBenchmarks.create()
                if let duckdb_instance = self.duckdb_instance {
                    let startTime = CFAbsoluteTimeGetCurrent()
                    try duckdb_instance.Load(tpch_data : results)
                    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                    self.duckdb_load_time = "DuckdbLoad using appender sf=0.001 = \(timeElapsed)"
                    self.state = .data_is_converted
                } else {
                    print("error with creating duckdb instance")
                }
            }
        }
        
    }
    
    private func QueryDataRealm() {
        self.state = .querying_data
        Task {
            if let tpch_data {
                let startTime = CFAbsoluteTimeGetCurrent()
                try RealmObjects.GetLineItem()
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                self.realm_query_time = "Realm Get lineitem time = \(timeElapsed)"
                self.state = .data_is_queried
            } else {
                self.state = .loading_error
            }
        }
    }
    
    private func QueryDataDuckDB() {
        self.state = .querying_data
        Task {
            if let duckdb_instance = self.duckdb_instance {
                let startTime = CFAbsoluteTimeGetCurrent()
                let results = try duckdb_instance.GetLineItem()
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                self.duckdb_query_time = "DuckDB Get lineitem time = \(timeElapsed)"
                let l_orderkey = results[0].cast(to: Int.self)
                let l_partkey = results[1].cast(to: Int.self)
                let l_suppkey = results[2].cast(to: Int.self)
                let l_linenumber = results[3].cast(to: Int.self)
                let l_returnflag = results[4].cast(to: String.self)
                let l_linestatus = results[5].cast(to: String.self)
                let l_shipinstruct = results[6].cast(to: String.self)
                let l_shipmode = results[7].cast(to: String.self)
                let l_shipcomment = results[8].cast(to: String.self)
                print("there are \(results.rowCount) results")
                print(l_orderkey)
                self.state = .data_is_queried
            } else {
                self.state = .loading_error
            }
        }
    }
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
