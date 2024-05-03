import SwiftUI

@main
struct EmmetApp: App {
    @StateObject private var dataController = DataController()
    @StateObject var locationManager: LocationManager = .init()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ItineraryView()
                    .tabItem {
                        Label("Itinerary", systemImage: "text.book.closed")
                    }
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(locationManager)
                ExplorerView()
                    .tabItem {
                        Label("Explorer", systemImage: "globe.americas")
                    }
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(locationManager)
            }
        }
    }
}
