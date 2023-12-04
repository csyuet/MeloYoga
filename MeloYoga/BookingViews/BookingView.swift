//
//  BookingView.swift
//  MeloYoga
//

import SwiftUI
import CoreData

struct BookingView: View {
    @StateObject private var calendarViewModel = CalendarViewModel()
    @StateObject var courseFilter: CourseFilter = CourseFilter()
    @Environment(\.managedObjectContext) private var viewContext

    var user: User
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CourseOfWeek.startTime, ascending: true)],
        animation: .default)
    var courses: FetchedResults<CourseOfWeek>

    @State private var weekIndex = 1
    @State private var showBookingForm = false
    @State private var courseToBook: CourseOfWeek?
    
    @State private var showSortForm = false
    @State var selectedDate = Date()

    @State private var showFilterForm = false
   
    func isBooked(course: CourseOfWeek) -> Bool{

        let children = course.child!.filtered(using: courseFilter.onday).sortedArray(using: [NSSortDescriptor(keyPath: \Course.startTime, ascending: true)]) as! [Course]
        if children.count == 0 {
            return false
        } else {
            for i in 0..<children.count {
                if children[i].students == user{
                    return true
                }
            }
            return false
        }
    }
    
    var body: some View {
        VStack{
            HStack {
                Image(systemName: "list.bullet.clipboard.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text("Booking Schedule")
                    .font(.title)
                    .bold()
            }.frame(height: 30)
            
            ZStack{
                Color.bluebg2
                VStack(alignment: .center){
                    Text(calendarViewModel.selectedDate, formatter: itemFormatter(format: "d MMMM YYYY"))
                        .fontWeight(.heavy)
                        .frame(width: 430, height: 25)
                        .padding(5)
                    ZStack {
                        Color.white
                        WeeksView()
                            .environmentObject(calendarViewModel)
                            .padding(.leading, 20).padding(.trailing, 20)
                    }
                    Spacer()
                }
            }
            .frame(height: 125)
            .foregroundStyle(Color.blueword)
            
            HStack{
                Button{
                    showSortForm = true
                } label:{
                    Text("Sort by")
                    Image(systemName: "chevron.down")
                }.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .background(Color.bluebg)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Button{
                    showFilterForm = true
                } label:{
                    Text("Filter by")
                    Image(systemName: "chevron.down")
                }
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                .background(Color.bluebg)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                Spacer()
                Image(systemName: "calendar")
                    .resizable()
                    .frame(width: 33, height: 30)
                    .overlay{
                         DatePicker(
                             "",
                             selection: $calendarViewModel.selectedDate,
                             in: Date()...,
                             displayedComponents: [.date]
                         ).accentColor(Color.blueword)
                          .blendMode(.destinationOver)
                          .onChange(of: calendarViewModel.selectedDate){
                              withAnimation{
                                  calendarViewModel.fetchWeeks(date: calendarViewModel.selectedDate)
                              }
                          }
                      }

            }.fontWeight(.semibold)
            .foregroundStyle(Color.blueword)
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            Divider().frame(height: 3).overlay(.pinkbg2)
            
            if courses.count == 0 {
                VStack{
                    Spacer()
                    Image(systemName: "exclamationmark.magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200, alignment: .center)
                    Text("Unable to find any classes for this day")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .bold()
                    Spacer()
                }
            } else {
                List {
                    ForEach(courses) { course in
                        HStack{
                            VStack{
                                Text(timeFormat(time: course.startTime!))
                                Text("|")
                                Text(timeFormat(time: course.endTime!))
                            }
                            VStack(alignment: .leading){
                                Text(course.type!.uppercased())
                                Text(course.name!)
                                    .font(.headline)
                                Text("w/ \(course.coach!)")
                            }
                            
                            Spacer()
                            VStack(alignment: .trailing){
                                Spacer()
                                Text("\(course.cred) cred")
                                Spacer()
                                Button {
                                    courseToBook = course
                                } label: {
                                    Text(isBooked(course: course) ? "BOOKED" : "BOOK")
                                        .font(.system(size: 15))
                                        .bold()
                                        .foregroundColor(Color.pinkword)
                                    .frame(width: 80, height: 17, alignment: .top)
                                }
                                .disabled(isBooked(course: course))
                                .frame(width: 80, height: 21)
                                .background(isBooked(course: course) ? Color.pinkbg : Color.pinkbg2)
                                .cornerRadius(3)
                                Spacer()
                            }
                            
                        }
                    }.listRowSeparatorTint(.pinktint)
                }
                .listStyle(.inset)
            }
        }
        .onAppear{
            courses.nsPredicate = courseFilter.customPredicate
        }
        .onChange(of: calendarViewModel.selectedDate){
            withAnimation {
                courseFilter.exactDate(date: calendarViewModel.selectedDate)
                courseFilter.filterUpdate()
                courses.nsPredicate = courseFilter.customPredicate
            }
        }
        
        .onChange(of: courseToBook){
            if courseToBook != nil {
                showBookingForm = true
            }
        }
        .onChange(of: showBookingForm){
            if !showBookingForm{
                courseToBook = nil 
            }
        }
        .sheet(isPresented: $showBookingForm){
            ConfirmationView(user: user, course: courseToBook!)
                .environmentObject(calendarViewModel)
                .presentationDetents([.height(500)])
        }
        .sheet(isPresented: $showSortForm){
            SortFormView()
                .environmentObject(courseFilter)
                .presentationDetents([.height(500)])
                .onDisappear {
                    withAnimation {
                        courses.nsSortDescriptors = courseFilter.customSort
                    }
                }
        }
        .sheet(isPresented: $showFilterForm){
            FilterFormView(selectedDate: calendarViewModel.selectedDate)
                .environmentObject(courseFilter)
                .presentationDetents([.height(500)])
                .onDisappear {
                    withAnimation {
                        courseFilter.filterUpdate()
                        courses.nsPredicate = courseFilter.customPredicate
                    }
                }
        }
    }
}

//#Preview {
//    BookingView(userIndex: 0)
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//        .environmentObject(CalendarViewModel())
//}
struct BookingViewPreview: PreviewProvider{
    static var previews: some View{
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(CourseDataModel())
            .environmentObject(PackageDataModel())
    }
}
