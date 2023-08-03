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
        case loading(Error?)
        case ready_for_data_conversion(TPCHData)
        case data_queried(DataFrame)
    }
    
    @State private var state = ViewState.loading(nil)
    

    var body: some View {
         Group {
           switch state {
           case .ready_for_data_conversion(_):
                Text("Data has been loaded")
                // execute some simple query in duckdb and get the timing.
           case .loading(nil):
               ProgressView { Text("Loading Exoplanets") }
           case .loading(let error?):
               Text("Error getting data")
               Text("\(error.localizedDescription)")
           case .data_queried(_):
               Text("SUCK MY ASSHOLE")
           default:
               Text("I don't know")
           }
         }
         .task {
           await prepareDuckdbTPCH()
         }
    }

    private func prepareDuckdbTPCH() async {
        guard case .loading(_) = state else { return }
        self.state = .loading(nil)
        do {
            let tpch_data = try await TPCHData.create()
            self.state = .ready_for_data_conversion(tpch_data)
            self.state = try await .data_queried(tpch_data.GetLineItem())
        }
        catch {
          self.state = .loading(error)
        }
    }
    
    private func ConvertData(tpch_data : TPCHData) {
        guard case .loading(_) = state else { return }
        self.state = .loading(nil)
        Task {
            let lineitem_data = try await tpch_data.GetLineItem();
            self.state = .data_queried(lineitem_data)
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
