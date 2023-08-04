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
    
//    private init() {
//        self.tpch_data
//        
//    }
    

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
        VStack {
            Button("Load Data") {
                loadData()
            }
            .padding()
            
            Button("Query Data") {
                QueryData()
            }
            .padding()
            
            Button("Convert Data") {
                ConvertData()
            }
            
            Button("Query Realm Data") {
                QueryRealmData()
            }
            .padding()
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
    
    private func QueryRealmData() {
        Task {
            try RealmObjects.Query()
        }
    }
    
    private func ConvertData() {
        self.state = .converting_data
        Task {
            if let tpch_data {
                let results = try await tpch_data.GetLineItem()
                try RealmObjects.Load(tpch_data : results)
            }
        }
        self.state = .data_is_converted
    }
    
    private func QueryData() {
        guard case .data_is_loaded = state else { return }
        self.state = .querying_data
        Task {
            if let tpch_data {
                let results = try await tpch_data.GetLineItem()
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
