//
//  HomeView.swift
//  MeloYoga
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var calendarViewModel = CalendarViewModel()
    @StateObject var courseFilter: CourseFilter = CourseFilter()

    var user: User
    @State private var selectedDate: Date = Date()
    @State private var weekIndex: Int = 1
    
    @State private var bookedCourses: [Course] = []
    @Binding var tabIndex: Int
    
    var body: some View {
    
        VStack(alignment: .center){
            HStack{
                Image("logo")
                    .resizable()
                    .frame(width: 30, height: 45)
                Text("Welcome, \((user.name!.components(separatedBy: " ").first!).capitalized) !")
                    .font(.title)
                    .foregroundStyle(Color.pinkword)
                Spacer()
                if user.icon == nil {
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .frame(width: 30, height: 30)
                } else {
                    Image(user.icon!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .frame(width: 30, height: 30)
                }
            }
            .fontWeight(.bold)
            
            Spacer()
            VStack {
                HStack{
                    Text("Upcoming lessons:")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(Color.blueword)
                        .padding(.bottom, 1)
                    Spacer()
                }
                
                ZStack {
                    Color.bluebg2
                    VStack(alignment: .center, spacing: 5){
                        Text("\(calendarViewModel.selectedDate, formatter: itemFormatter(format: "d MMMM YYYY"))")
                            .fontWeight(.heavy)

                        ZStack {
                            Color.white
                            WeekView(week: calendarViewModel.curWeek, enabled: false)
                                .environmentObject(calendarViewModel)
                                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                        }
                        .frame(height: 80)
                        
                        ZStack {
                            Color.white
                            VStack{
                                HStack{
                                    Text("Bookings: \(bookedCourses.count)")
                                    Spacer()
                                    Button{
                                        tabIndex = 1
                                    }label: {
                                        Text("View Class Schedule")
                                        Image(systemName: "chevron.right")
                                    }
                                }.fontWeight(.bold)
                                .padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 5))
                                
                                ScrollView(.horizontal){
                                    
                                    HStack {
                                        if bookedCourses.count == 0 {
                                            Spacer()
                                            Image(systemName: "exclamationmark.magnifyingglass")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25, height: 25, alignment: .center)
                                            Text("No upcomming booking")
                                                .font(.system(size: 20))
                                                .multilineTextAlignment(.center)
                                                .bold()
                                        } else {
                                            ForEach(bookedCourses) { course in
                                                CoursesView(course: course)
                                            }
                                        }
                                    }
                                    .frame(height: 90)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                                }.padding(.leading, 10)
                                .disabled(bookedCourses.count == 0)
                            }
                        }.clipShape(.rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 10,
                            bottomTrailingRadius: 10,
                            topTrailingRadius: 0
                            ))
                    }
                    .padding(5)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .foregroundStyle(Color.blueword)
            .onAppear{
                bookedCourses = courseFilter.upcomingCourses(user: user)
            }
            
            HStack {
                Text("Recent activities:")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(Color.pinkword)
                .padding(.bottom, 1)
                Spacer()
            }
            HStack{
                LazyVStack{
                    Image(systemName: "heart.fill")
                        .resizable()
                        .frame(width: 120, height: 100, alignment: .center)
                        .foregroundStyle(Color.pinkbg2)
                        .overlay {
                            Text("68")
                                .font(.system(size: 30))
                                .bold()
                        }
                    Text("Heart Rate").bold()
                }.foregroundStyle(Color.pinkword)
                Spacer()
                LazyVStack {
                    Image(systemName: "sun.min.fill")
                        .resizable()
                        .frame(width: 100, height: 100, alignment: .center)
                        .foregroundStyle(Color.bluebg2)
                        .overlay {
                            Text("3")
                                .font(.system(size: 30))
                                .bold()
                        }
                    Text("Your weekly goal").bold()
                }.foregroundStyle(Color.blueword)
            }
            Spacer()
            
            ZStack{
                Color.pinkbg
                VStack(alignment:.leading, spacing: 5){
                    Text("What's new?")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.pinkword)
                    Divider().frame(height: 3).overlay(.pinkbg2)
                    ScrollView{
                        Text("Dear valued members and yoga enthusiasts:\nWe're thrilled to share some wonderful updates from Melo Yoga that we think you'll be delighted to hear about:\n\n1. New Class Schedule: Starting from next month, we're introducing an extended class schedule that includes more diverse yoga styles, levels, and times to accommodate your busy lives. Whether you're an early bird or a night owl, there's a class for you!\n\n2. Yoga Retreat Announcement: Mark your calendars for our upcoming yoga retreat to the serene mountains! Join us for a rejuvenating weekend filled with meditation, yoga, and nature. Details and registration will be available soon.\n\n3. Yoga Challenge: Get ready to challenge yourself with our 30-day yoga challenge! Starting in November, participate in daily practices, set new goals, and be eligible to win amazing prizes and a special studio membership discount.\n\n4. New Instructor: We're excited to welcome a new yoga instructor to our team. Their expertise in mindfulness and relaxation will add a fresh perspective to your practice. Stay tuned for their class schedule.\n\n5. Studio Renovations: Melo Yoga is getting a makeover! We're renovating our space to create a more inviting and serene ambiance for your practice. The renovations will be complete by the end of the month.\n\n6. Member Appreciation Day: As a token of our gratitude, we're hosting a Member Appreciation Day on the last Sunday of this month. Enjoy free workshops, snacks, and exclusive discounts for all active members.\n\nKeep an eye on our website, social media, and your email for further details and registration links. We can't wait to embark on these exciting changes and experiences with you.\n\nThank you for being a part of our Melo Yoga community, and we look forward to seeing you on the mat!\n\nWith peace and gratitude,\nThe Melo Yoga Team 🧘🌸")
                        .font(
                        Font.custom("Inter", size: 15)
                        .weight(.semibold)
                        )
                        .foregroundColor(Color.pinkword)
                    }
                
                }.padding()
            }.clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 15))
    }
}

//#Preview {
//    HomeView(userIndex: 0)
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//        
//}

struct ContentViewPreview: PreviewProvider{
    static var previews: some View{
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(CourseDataModel())
            .environmentObject(PackageDataModel())
    }
}
