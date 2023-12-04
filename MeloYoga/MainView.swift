//
//  MainView.swift
//  MeloYoga
//

import SwiftUI

struct MainView: View {
    var user: User
    @Binding var login: Bool
    @State private var tabIndex: Int = 0
    
    var body: some View{
        TabView(selection: $tabIndex){
            Group{
                HomeView(user: user, tabIndex: $tabIndex)
                    .tabItem {
                        Image(systemName: "house.fill").font(.system(size: 26))
                        Text("Home")
                    }.tag(0)
                    
                BookingView(user: user)
                    .tabItem {
                        Image(systemName: "book.closed.fill")
                        Text("Booking")
                    }.tag(1)
                
                PurchaseView(user: user)
                    .tabItem {
                        Image(systemName: "dollarsign.circle.fill")
                        Text("Purchase")
                    }.tag(2)
                
                ProfileView(user: user, login: $login, tabIndex: $tabIndex)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }.tag(3)
            }
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(Color.pinkbg2)
        }
        .onAppear(){
            UITabBar.appearance().unselectedItemTintColor = UIColor(Color.pinkword)
            UITabBar.appearance().scrollEdgeAppearance?.backgroundColor = UIColor(Color.pinkbg2)
            UITabBar.appearance().barTintColor = UIColor(Color.pinkbg2)
            UITabBar.appearance().backgroundColor = UIColor(Color.pinkbg2)
        }
        .tint(Color.pinktint)
        
    }
}

//#Preview {
//    MainView(loginUser: 0)
//}
//
struct MainViewPreview: PreviewProvider{
    static var previews: some View{
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(CourseDataModel())
            .environmentObject(PackageDataModel())
    }
}
