//
//  PurchaseHistoryView.swift
//  MeloYoga
//

import SwiftUI

struct PurchaseHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var user: User
    @Binding var tabIndex: Int
    
    let available = NSPredicate(format: "expDate > %@ && remainingCred > 0", Date() as NSDate)
    let expired = NSPredicate(format: "(expDate <= %@) || (remainingCred == 0)", Date() as NSDate, 0 as NSInteger)
    @State var availablePackages: [PurchasedPackage] = []
    @State var expiredPackages: [PurchasedPackage] = []
    @State var availableCred: Int16 = 0
    
    var body: some View {
        
        NavigationView {
            List{
                HStack{
                    Text("Credits remaining: ")
                    Spacer()
                    Text("\(availableCred)")
                }
                
                Section("Available") {
                    ForEach(availablePackages) { package in
                        VStack(alignment: .leading){
                            Text("\(package.remainingCred)/\(package.packageType!.totalCredit) - \(package.packageType!.totalCredit) credits package (\(package.packageType!.expiry) months' expiry)")
                                .bold()
                            
                            HStack{
                                Text("Purchased Date:")
                                Spacer()
                                Text(package.purDate!, formatter: itemFormatter(format: "dd/MM/YYYY"))
                            }.foregroundStyle(Color.gray)
                            
                            HStack{
                                Text("Expire Date:")
                                Spacer()
                                Text(package.expDate!, formatter: itemFormatter(format: "dd/MM/YYYY"))
                            }.foregroundStyle(Color.gray)
                        }
                    }
                    if availablePackages.count == 0 {
                        HStack{
                            Text("No available package")
                            Spacer()
                            Button{
                                withAnimation {
                                    tabIndex = 2
                                }
                            } label:{
                                Text("Go purchase one!")
                                    .bold()
                            }
                            .cornerRadius(3)
                        }
                    }
                }.headerProminence(.increased)
                
                Section("Expired"){
                    ForEach(expiredPackages) { package in
                        VStack(alignment: .leading){
                            Text("\(package.remainingCred)/\(package.packageType!.totalCredit) - \(package.packageType!.totalCredit) credits package")
                                .bold()
                            Text("(\(package.packageType!.expiry) months' expiry)")
                            HStack{
                                Text("Purchased Date:")
                                Spacer()
                                Text(package.purDate!, formatter: itemFormatter(format: "dd/MM/YYYY"))
                            }.foregroundStyle(Color.gray)
                            
                            HStack{
                                Text("Expire Date:")
                                Spacer()
                                Text(package.expDate!, formatter: itemFormatter(format: "dd/MM/YYYY"))
                            }.foregroundStyle(Color.gray)
                        }
                    }
                    if expiredPackages.count == 0{
                        Text("No expired package")
                    }
                }
                .headerProminence(.increased)
            }
            .listStyle(.sidebar)
            
        }
        .navigationTitle("Purchase History")
        .onAppear{
            availableCred = 0
            availablePackages = (user.purchased!.filtered(using: available).sortedArray(using: [NSSortDescriptor(keyPath: \PurchasedPackage.expDate, ascending: true)]) as! [PurchasedPackage])
            
            for i in 0..<availablePackages.count {
                availableCred += availablePackages[i].remainingCred
            }
            
            expiredPackages = (user.purchased!.filtered(using: expired).sortedArray(using: [NSSortDescriptor(keyPath: \PurchasedPackage.purDate, ascending: true)]) as! [PurchasedPackage])
        }
    }
    
    
}

//#Preview {
//    MyCreditsView()
//}

//struct MyCreditsPreview: PreviewProvider{
//    static var previews: some View {
//        ProfileView(userIndex: 0)
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//
//    }
//}
