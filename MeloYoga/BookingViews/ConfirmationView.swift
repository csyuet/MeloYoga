//
//  ConfirmationView.swift
//  MeloYoga
//

import SwiftUI

struct ConfirmationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    var user: User
    var course: CourseOfWeek
    
    @State private var packages: [PurchasedPackage] = []
    @State private var creds: Int16 = 0
    @State private var booked = false
    @State private var validBooking = ""
    
    @State var st: Date = Date()
    @State var et: Date = Date()
    
    func toCourse(course: CourseOfWeek) -> Course{
        let c = Course(context: viewContext)
        c.id = UUID()

        var comps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: calendarViewModel.selectedDate)
        let s = course.startTime!.index(course.startTime!.startIndex, offsetBy: 2)
        comps.hour = Int(course.startTime![..<s])
        comps.minute = Int(course.startTime![s...])
        c.startTime = Calendar.current.date(from: comps)
        let e = course.endTime!.index(course.endTime!.startIndex, offsetBy: 2)
        comps.hour = Int(course.endTime![..<e])
        comps.minute = Int(course.endTime![e...])
        c.endTime = Calendar.current.date(from: comps)
        
        return c
    }
    
    func useCred(){
        var cost = course.cred
        for i in 0..<packages.count{
            if cost > packages[i].remainingCred{
                cost -= packages[i].remainingCred
                packages[i].remainingCred = 0
            } else {
                packages[i].remainingCred -= cost
            }
        }
        let c = toCourse(course: course)
        course.addToChild(c)
        user.addToBooked(c)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        booked = true
    }
    
    var body: some View {
        if booked {
            LazyVStack{
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                Text("Your booking has completed!")
                    .font(.title)
                Text("Enjoy your yoga time!")
                    .font(.title2)
            }
        } else {
            List{
                Section("Selected Course") {
                    VStack(alignment: .leading){
                        Group{
                            Text("\(course.type!.uppercased())")
                            Text("\(course.name!) (\(course.cred))")
                                .bold()
                            Text("w/ \(course.coach!)")
                        
                            Text("\(calendarViewModel.selectedDate, formatter: itemFormatter(format: "EEEE, d MMM")) \(timeFormat(time:course.startTime!)) - \(timeFormat(time:course.endTime!))")
                        }
                    }
                }.headerProminence(.increased)
                
                Section("Available Packages") {
                    ForEach(packages) { package in
                        VStack(alignment: .leading){
                            Text("\(package.remainingCred)/\(package.packageType!.totalCredit) - \(package.packageType!.totalCredit) credits package")
                                .bold()
                            Text("(\(package.packageType!.expiry) months' expiry)")
                            Text("Expire in \(package.expDate!, formatter: itemFormatter(format: "dd/MM/YYYY"))").foregroundStyle(Color.gray)
                        }
                    }
                    if packages.count == 0 {
                        HStack{
                            Spacer();Text("None");Spacer()
                        }
                    }
                }.headerProminence(.increased)
                
                ZStack {
                    Button {
                        useCred()
                    } label: {
                        HStack {
                            Spacer(); Text(validBooking.isEmpty ? "BOOK" : validBooking).bold(); Spacer()
                        }
                    }
                    .disabled(booked || !validBooking.isEmpty)
                }
                .listRowBackground(validBooking.isEmpty ? Color.pinkword : Color.pinkbg)
                .tint(validBooking.isEmpty ? Color.white : Color.pinktint)
                
            }
            .onAppear{
                packages = (user.purchased!.filtered(using: NSPredicate(format: "expDate > %@ && remainingCred > 0", Date() as NSDate)).sortedArray(using: [NSSortDescriptor(keyPath: \PurchasedPackage.expDate, ascending: true)]) as! [PurchasedPackage])
                let target = course.cred
                
                if packages.count == 0 {
                    validBooking = "NO CREDITS"
                } else {
                    for i in 0..<packages.count{
                        let pay = packages[i].remainingCred
                        if target > pay {
                            if i == packages.count - 1{
                                validBooking = "NOT ENOUGH CREDITS"
                            }
                        }
                    }
                }
                
            }
        }
            
        
    }
}


//#Preview {
//    ConfirmationView(userIndex: 0, courseIndex: 0)
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
struct ConfirmationPreview: PreviewProvider{
    static var previews: some View{
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(CourseDataModel())
            .environmentObject(PackageDataModel())
    }
}
