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


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    private enum ViewState {
        case loading(Error?)
        case ready(TPCHData)
    }
    
    @State private var state = ViewState.loading(nil)
    
    var body: some View {
         Group {
           switch state {
           case .ready(let tpch_data):
              Text("Data Ready")
            
               // execute some simple query in duckdb and get the timing.
           case .loading(nil):
             ProgressView { Text("Loading Exoplanets") }
           case .loading(let error?):
             Text("Error getting data")
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
          self.state = .ready(try await TPCHData.create())
        }
        catch {
          self.state = .loading(error)
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
