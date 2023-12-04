//
//  MeloYogaApp.swift
//  MeloYoga
//

import SwiftUI

@main
struct MeloYogaApp: App {
    @StateObject private var courseData = CourseDataModel()
    @StateObject private var packageData = PackageDataModel()
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(courseData)
                .environmentObject(packageData)
                .preferredColorScheme(.light)
        }
    }
}
