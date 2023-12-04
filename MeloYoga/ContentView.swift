//
//  ContentView.swift
//  MeloYoga
//

import SwiftUI
import CoreData

func timeFormat(time: String) -> String{
    let h = time.index(time.startIndex, offsetBy: 2)
    if time[..<h] > "11" {
        if time[..<h] == "12"{
            return time[..<h] + ":" + time[h...] + " PM"
        } else{
            let hr = (Int(time[..<h]) ?? 13) - 12
            return String(hr) + ":" + time[h...] + " PM"
        }
    }
    
    return time[..<h] + ":" + time[h...] + " AM"
}

func itemFormatter(format: String) -> DateFormatter{
    let formatter = DateFormatter()
    if format == "t"{
        formatter.timeStyle = .short
    } else{
        formatter.dateFormat = format
    }
    return formatter
}

struct ContentView: View {
    @EnvironmentObject var courseData: CourseDataModel
    @EnvironmentObject var packageData: PackageDataModel
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.name, ascending: false)],
        animation: .default)
    private var users: FetchedResults<User>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CourseOfWeek.weekday, ascending: true)],
        animation: .default)
    private var wcourses: FetchedResults<CourseOfWeek>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Package.cost, ascending: true)],
        animation: .default)
    private var packages: FetchedResults<Package>
    
    @State var login: Bool = true
    @State var loginUser: Int = 0
    
    func addPackage(packageData: PackageDataModel){
        for i in 0..<packageData.packages.count{
            let package = Package(context: viewContext)
            package.id = UUID()
            package.cost = packageData.packages[i].cost
            package.expiry = packageData.packages[i].expiry
            package.totalCredit = packageData.packages[i].totalCredit
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func addWeekCourse(courseData: CourseDataModel){
        let courses = courseData.wcourses
        for i in 0..<courses.count {
            let course = CourseOfWeek(context: viewContext)
            course.id = UUID()
            course.name = courses[i].name
            course.coach = courses[i].coach
            course.cred = courses[i].cred
            course.type = courses[i].type
            course.weekday = courses[i].weekday
            course.startTime = courses[i].startTime
            course.endTime = courses[i].endTime
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    
    var body: some View {
        VStack{
        }.onAppear{
            if users.count > 0 {
                for i in 0..<users.count {
                    if users[i].login {
                        login = true
                        loginUser = i
                    }
                }
            }
            if wcourses.isEmpty{
                addWeekCourse(courseData: courseData)
            }
            if packages.isEmpty{
                addPackage(packageData: packageData)
            }
        }
        
        if login{
            MainView(user: users[loginUser], login: $login)
        }
        else {
            NavigationStack{
                Image("logo")
                Text("Melo Yoga")
                    .font(.largeTitle)
                NavigationLink(destination: NewAcView()) {
                    ZStack{
                        Color.pinkbg2
                        Text("Create New Account")
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.pinkword)
                    }.frame(width: 290, height: 60, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                NavigationLink(destination: LoginView(login: $login, users: users, loginUser: $loginUser)) {
                    ZStack{
                        Color.bluebg2
                        Text("Login")
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.blueword)
                            .multilineTextAlignment(.center)
                    }.frame(width: 290, height: 60, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
        }
    }
}

struct LoginView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var login: Bool
    var users: FetchedResults<User>
    @Binding var loginUser: Int
    
    @State private var inputName = ""
    @State private var inputpw = ""
    @State private var user: User?
        
    @State private var loginState: String = ""
    
    var body: some View {
        
        TextField("Your Username", text: $inputName)
        .padding()
        .frame(width: 300, height: 45)
        .background(Color.bluebg2)
        .cornerRadius(15)
        
        SecureField("Your password", text: $inputpw)
        .padding()
        .frame(width: 300, height: 45)
        .background(Color.bluebg2)
        .cornerRadius(15)
        
        Button {
            for i in 0..<users.count{
                if inputName == users[i].name && inputpw == users[i].pw {
                    login = true
                    users[i].login = true
                    loginUser = i
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
            }
            if login == false {
                loginState = "Login Failed: Wrong username or password."
            }

        } label: {
            ZStack{
               Color.bluebg2
               Text("Login")
                   .font(.system(size: 25))
                   .fontWeight(.semibold)
                   .foregroundStyle(Color.blueword)
                   .multilineTextAlignment(.center)
           }
            .frame(width: 188, height: 50)
           .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        Text(loginState)
            .foregroundStyle(.red)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(CourseDataModel())
        .environmentObject(PackageDataModel())
}
