//
//  ProfileView.swift
//  MeloYoga
//


import SwiftUI
import CoreData

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var user: User
    @State private var logoutAlert = false
    @Binding var login: Bool
    @Binding var tabIndex: Int
    
    var body: some View {
        
        ZStack {
            Color.pinkbg
            VStack{
                ZStack{

                    HStack {
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Text("My Profile")
                            .font(.title)
                            .bold()
                    }.frame(height: 30)
                    
                    HStack{
                        Spacer()
                        Button{
                            logoutAlert = true
                        } label: {
                            Text("Log out")
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                        .foregroundColor(.pinktint)
                        .bold()
                        .alert("Log Out", isPresented: $logoutAlert) {
                            Button("No", role: .cancel){}
                            Button("Yes", role: .destructive) {
                                withAnimation{
                                    user.login = false
                                    login = false
                                }
                                do {
                                    try viewContext.save()
                                } catch {
                                    let nsError = error as NSError
                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                }
                            }
                        } message: {
                            Text("Are you sure to log out this account?")
                        }
                    }
                }
                ZStack{
                    Circle()
                        .frame(width: 155, height: 155)
                        .foregroundStyle(.pinkbg2)
                    
                    if user.icon == nil {
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width: 150, height: 150)
                    } else {
                        Image(user.icon!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width: 150, height: 150)
                    }
                }
                
                Text(user.name!)
                    .font(.title2)
                    .bold()
                
                NavigationStack{
                    VStack {
                        NavigationLink(destination: BookingHistoryView(user: user, tabIndex: $tabIndex)) {
                            VStack{
                                Text("Booking history")
                                Image(systemName: "clock.fill")
                                    .resizable()
                                    .frame(width: 170, height: 170, alignment: .center)
                            }
                        }
                        Divider().frame(height: 3).overlay(.pinkbg2)
                        NavigationLink(destination: PurchaseHistoryView(user: user, tabIndex: $tabIndex)) {
                            VStack{
                                Text("My credits & Purchase history")
                                Image(systemName: "dollarsign.arrow.circlepath")
                                    .resizable()
                                    .frame(width: 190, height: 170, alignment: .center)
                            }
                        }
                    }
                    .font(.system(size: 25))
                    .foregroundStyle(Color.pinkword)
                    .bold()
                }
                
            }.padding(.top, 50)
        }
        .tint(Color.pinktint)
        .ignoresSafeArea(.all)
    }
}

struct ProfileViewPreview: PreviewProvider{
    static var previews: some View{
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(CourseDataModel())
            .environmentObject(PackageDataModel())
    }
}
