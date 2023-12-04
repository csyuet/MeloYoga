//
//  PurchaseView.swift
//  MeloYoga
//

import SwiftUI
import CoreData

struct PurchaseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Package.cost, ascending: true)],
        animation: .default)
    private var packages: FetchedResults<Package>

    var user: User
    @State private var packageToBuy: Package?
    @State private var showPurchaseForm = false
    
    var body: some View {
        
        VStack{
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text("Package Purchase")
                    .font(.title)
                    .bold()
            }.frame(height: 30)
            
            List {
                ForEach((packages), id: \.self){ package in
                    HStack {
                        VStack(alignment: .leading){
                            Text("\(package.totalCredit) credits package - \(package.cost)")
                                .bold()
                            Text("(\(package.expiry) months' expiry)")
                        }
                        Spacer()
                        Button {
                            packageToBuy = package
                        } label: {
                            Text("Buy")
                                .font(.system(size: 15))
                                .bold()
                            .foregroundColor(Color(red: 0.74, green: 0.58, blue: 0.58))
                        }
                        .frame(width: 80, height: 21)
                        .background(Color(red: 0.99, green: 0.81, blue: 0.87))
                        .cornerRadius(3)
                    }
                    
                }
            }
            .onChange(of: packageToBuy){
                if packageToBuy != nil {
                    showPurchaseForm = true
                }
            }
            .onChange(of: showPurchaseForm){
                if !showPurchaseForm{
                    packageToBuy = nil
                }
            }
        }.sheet(isPresented: $showPurchaseForm){
            PurchaseFormView(user: user, package: packageToBuy!)
                .presentationDetents([.height(500)])
        }
        
    }
}


//#Preview {
//    PurchaseView(userIndex: 0)
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}

struct PurchaseViewPreview: PreviewProvider{
    static var previews: some View{
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(CourseDataModel())
            .environmentObject(PackageDataModel())
    }
}
