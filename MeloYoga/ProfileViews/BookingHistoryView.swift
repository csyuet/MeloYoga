//
//  BookingHistoryView.swift
//  MeloYoga
//


import SwiftUI

struct BookingHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var courseFilter: CourseFilter = CourseFilter()
    var user: User
    @Binding var tabIndex: Int
    
    @State private var cancelCourse: Course?
    @State private var cancelAlert = false

    @State var upcomingCourses: [Course] = []
    @State var previousCourses: [Course] = []
    
    func cancel(course: Course){
        viewContext.delete(course)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func historyUpdate(){
        upcomingCourses = courseFilter.upcomingCourses(user: user)
        previousCourses = courseFilter.previousCourses(user: user)
    }
    
    var body: some View {
        
        NavigationView {
            List{
                Section("Upcoming") {
                    ForEach(upcomingCourses) { course in
                        VStack(alignment: .leading) {
                            Text(course.startTime!, formatter: itemFormatter(format: "EEEE, MMM d - YYYY"))
                                    .foregroundStyle(Color.gray)
                            HStack{
                                VStack{
                                    Text(course.startTime!, formatter: itemFormatter(format: "t"))
                                    Text("|")
                                    Text(course.endTime!, formatter: itemFormatter(format: "t"))
                                }
                                VStack(alignment: .leading){
                                    Text(course.parent!.type!.uppercased())
                                    Text("\(course.parent!.name!) (\(course.parent!.cred))")
                                        .font(.headline)
                                    Text("w/ \(course.parent!.coach!)")
                                }
                                Spacer()
                                Button {
                                    cancelAlert = true
                                    cancelCourse = course
                                } label: {
                                    Text("CANCEL")
                                    .font(
                                        Font.custom("Inter", size: 15)
                                        .weight(.medium)
                                    )
                                    .foregroundColor(Color.pinkword)
                                    .frame(width: 78.51852, height: 17, alignment: .top)
                                }
                                .background(Color.pinkbg2)
                                .cornerRadius(3)
                                .alert("Cancel Booking", isPresented: $cancelAlert, presenting: cancelCourse) {_ in
                                    Button("No", role: .cancel){}
                                    Button("Yes", role: .destructive) {
                                        user.removeFromBooked(cancelCourse!)
                                    }
                                } message: { _ in
                                    Text("Your Booking: \(cancelCourse!.parent!.name!) \nAre you sure to cancel this booking?")
                                }
                            }
                        }
                    }
                    if upcomingCourses.count == 0 {
                        HStack{
                            Text("No upcoming class")
                            Spacer()
                            Button{
                                withAnimation {
                                    tabIndex = 1
                                }
                            } label:{
                                Text("Go book one!")
                                    .bold()
                            }
                            .cornerRadius(3)
                        }
                        
                    }
                }.headerProminence(.increased)
                
                Section("Previous:"){
                    ForEach(previousCourses) { course in
                        VStack {
                            Text(course.startTime!, formatter: itemFormatter(format: "EEEE, MMM d - YYYY"))
                                    .foregroundStyle(Color.gray)
                            HStack {
                                VStack{
                                    Text(course.startTime!, formatter: itemFormatter(format: "t"))
                                    Text("|")
                                    Text(course.endTime!, formatter: itemFormatter(format: "t"))
                                }
                                VStack(alignment: .leading){
                                    Text(course.parent!.type!.uppercased())
                                    Text(course.parent!.name!)
                                        .font(.headline)
                                    Text("w/ \(course.parent!.coach!)")
                                }
                            }
                        }
                    }
                    if previousCourses.count == 0{
                        Text("No previous class")
                    }
                }
                .headerProminence(.increased)
            }
            .listStyle(.sidebar)
            
        }
        .navigationTitle("Booking History")
        .onAppear{
            historyUpdate()
        }.onChange(of: user.booked!.count) {
            historyUpdate()
        }
        
            
    }

}

//#Preview {
//    BookingHistoryView(userIndex: 0)
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}

//struct BookingHistoryPreview: PreviewProvider{
//    static var previews: some View {
//        ProfileView(userIndex: 0)
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
